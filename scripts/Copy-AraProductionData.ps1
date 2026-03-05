<#
.SYNOPSIS
    Copies legacy ARA tables from a read-only production database to a new
    database on the corporate network.

.DESCRIPTION
    Reads the 26 legacy tables required by Invoke-AraDataMigration.ps1 from the
    production database (read-only) and bulk-copies them into an empty target
    database (full access) on the corporate network.

    The target database must already exist (empty). The script creates the legacy
    table schema (without foreign keys) and copies all data, preserving original
    identity values.

    After copying, the script:
      - Compares row counts between source and target for every table
      - Validates that every SELECT query used by Invoke-AraDataMigration.ps1
        parses correctly against the copied data

    Authentication options:
      - SourceConnectionString / TargetConnectionString: Full connection strings
        supporting any auth method (SQL Auth, Windows Auth, etc.).
      - Individual parameters (SourceServer, SourceUser, etc.): Builds SQL Auth
        connection strings from separate fields.

    Prerequisites:
      - Target database must already exist (provision via SSMS or DBA request)
      - Both servers accessible from the machine running this script

.PARAMETER SourceConnectionString
    Full connection string for the production database. When provided,
    SourceServer, SourceDatabase, SourceUser, and SourcePassword are ignored.
    Example: "Server=prod-server;Database=ARA;Integrated Security=True;TrustServerCertificate=True;"

.PARAMETER TargetConnectionString
    Full connection string for the target database. When provided,
    TargetServer, TargetDatabase, TargetUser, and TargetPassword are ignored.
    Example: "Server=localhost;Database=ARA_Copy;Integrated Security=True;TrustServerCertificate=True;"

.PARAMETER SourceServer
    Hostname or IP of the production SQL Server.
    Ignored when SourceConnectionString is provided.

.PARAMETER SourceDatabase
    Name of the production database containing legacy ARA tables.
    Ignored when SourceConnectionString is provided.

.PARAMETER SourceUser
    SQL Auth username for the production database (read-only access).
    Ignored when SourceConnectionString is provided.

.PARAMETER SourcePassword
    SQL Auth password for the production database.
    Ignored when SourceConnectionString is provided.

.PARAMETER TargetServer
    Hostname or IP of the corporate network SQL Server.
    Ignored when TargetConnectionString is provided.

.PARAMETER TargetDatabase
    Name of the empty target database (must already exist).
    Ignored when TargetConnectionString is provided.

.PARAMETER TargetUser
    SQL Auth username for the target database (full access).
    Ignored when TargetConnectionString is provided.

.PARAMETER TargetPassword
    SQL Auth password for the target database.
    Ignored when TargetConnectionString is provided.

.PARAMETER SkipBinaryAttachments
    When specified, skips the binary_file column on the attachments table.
    Use this to speed up initial testing when attachment binaries are not needed.

.PARAMETER BulkCopyTimeout
    Timeout in seconds for each SqlBulkCopy operation. Default: 600 (10 minutes).

.EXAMPLE
    .\Copy-AraProductionData.ps1 `
        -SourceConnectionString "Server=prod-server;Database=ARA;Integrated Security=True;TrustServerCertificate=True;" `
        -TargetConnectionString "Server=localhost;Database=ARA_Copy;Integrated Security=True;TrustServerCertificate=True;"

.EXAMPLE
    .\Copy-AraProductionData.ps1 `
        -SourceServer "prod-sql-server" `
        -SourceDatabase "ARA" `
        -SourceUser "readonly_user" `
        -SourcePassword "P@ssw0rd" `
        -TargetServer "corp-sql-server" `
        -TargetDatabase "ARA_Copy" `
        -TargetUser "admin_user" `
        -TargetPassword "P@ssw0rd"

.EXAMPLE
    .\Copy-AraProductionData.ps1 `
        -SourceConnectionString "Server=prod-server;Database=ARA;User Id=readonly;Password=P@ss;TrustServerCertificate=True;" `
        -TargetConnectionString "Server=localhost;Database=ARA_Copy;User Id=sa;Password=P@ss;TrustServerCertificate=True;" `
        -SkipBinaryAttachments
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$SourceConnectionString,

    [Parameter()]
    [string]$TargetConnectionString,

    [Parameter()]
    [string]$SourceServer,

    [Parameter()]
    [string]$SourceDatabase,

    [Parameter()]
    [string]$SourceUser,

    [Parameter()]
    [string]$SourcePassword,

    [Parameter()]
    [string]$TargetServer,

    [Parameter()]
    [string]$TargetDatabase,

    [Parameter()]
    [string]$TargetUser,

    [Parameter()]
    [string]$TargetPassword,

    [Parameter()]
    [switch]$SkipBinaryAttachments,

    [Parameter()]
    [int]$BulkCopyTimeout = 600
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Ensure SqlServer module is available (provides Microsoft.Data.SqlClient)
# ---------------------------------------------------------------------------
# User-local module directory (no admin rights needed)
$localModulesDir = Join-Path $HOME '.psmodules'

# Add to PSModulePath so Get-Module and Import-Module can find saved modules
if ($env:PSModulePath -notlike "*$localModulesDir*") {
    $env:PSModulePath = "$localModulesDir$([IO.Path]::PathSeparator)$env:PSModulePath"
}

if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    Write-Host "SqlServer PowerShell module not found. Installing for current user..."

    if (-not (Test-Path $localModulesDir)) {
        New-Item -ItemType Directory -Path $localModulesDir -Force | Out-Null
    }

    # Save-Module downloads without requiring admin (no Install-Package dependency)
    Save-Module -Name SqlServer -Path $localModulesDir -Force
    Write-Host "  SqlServer module saved to $localModulesDir"
}

Import-Module SqlServer -ErrorAction Stop

# ---------------------------------------------------------------------------
# Build connection strings (from individual params if not provided directly)
# ---------------------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($SourceConnectionString)) {
    if ([string]::IsNullOrWhiteSpace($SourceServer) -or [string]::IsNullOrWhiteSpace($SourceDatabase) `
        -or [string]::IsNullOrWhiteSpace($SourceUser) -or [string]::IsNullOrWhiteSpace($SourcePassword)) {
        Write-Error "Provide either -SourceConnectionString or all of -SourceServer, -SourceDatabase, -SourceUser, -SourcePassword."
    }
    $SourceConnectionString = "Server=$SourceServer;Database=$SourceDatabase;User Id=$SourceUser;Password=$SourcePassword;Encrypt=True;TrustServerCertificate=True;"
}

if ([string]::IsNullOrWhiteSpace($TargetConnectionString)) {
    if ([string]::IsNullOrWhiteSpace($TargetServer) -or [string]::IsNullOrWhiteSpace($TargetDatabase) `
        -or [string]::IsNullOrWhiteSpace($TargetUser) -or [string]::IsNullOrWhiteSpace($TargetPassword)) {
        Write-Error "Provide either -TargetConnectionString or all of -TargetServer, -TargetDatabase, -TargetUser, -TargetPassword."
    }
    $TargetConnectionString = "Server=$TargetServer;Database=$TargetDatabase;User Id=$TargetUser;Password=$TargetPassword;Encrypt=True;TrustServerCertificate=True;"
}

# ---------------------------------------------------------------------------
# Helper: Open a SqlConnection
# ---------------------------------------------------------------------------
function Open-SqlConnection {
    param([string]$ConnectionString)
    $conn = [Microsoft.Data.SqlClient.SqlConnection]::new($ConnectionString)
    $conn.Open()
    return $conn
}

# ---------------------------------------------------------------------------
# Helper: Execute a non-query SQL statement
# ---------------------------------------------------------------------------
function Invoke-Sql {
    param(
        [string]$ConnectionString,
        [string]$Sql,
        [int]$Timeout = $BulkCopyTimeout
    )
    $conn = Open-SqlConnection -ConnectionString $ConnectionString
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $Sql
        $cmd.CommandTimeout = $Timeout
        [void]$cmd.ExecuteNonQuery()
    }
    finally {
        $conn.Close()
        $conn.Dispose()
    }
}

# ---------------------------------------------------------------------------
# Helper: Execute a scalar query
# ---------------------------------------------------------------------------
function Invoke-SqlScalar {
    param(
        [string]$ConnectionString,
        [string]$Sql
    )
    $conn = Open-SqlConnection -ConnectionString $ConnectionString
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $Sql
        $cmd.CommandTimeout = 120
        return $cmd.ExecuteScalar()
    }
    finally {
        $conn.Close()
        $conn.Dispose()
    }
}

# ---------------------------------------------------------------------------
# Helper: Read a DataTable
# ---------------------------------------------------------------------------
function Read-Table {
    param(
        [string]$ConnectionString,
        [string]$Query
    )
    $conn = Open-SqlConnection -ConnectionString $ConnectionString
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $Query
        $cmd.CommandTimeout = $BulkCopyTimeout
        $reader = $cmd.ExecuteReader()
        $table = [System.Data.DataTable]::new()
        $table.Load($reader)
        return $table
    }
    finally {
        $conn.Close()
        $conn.Dispose()
    }
}

# ---------------------------------------------------------------------------
# Helper: Bulk-copy a DataTable into a target table
# ---------------------------------------------------------------------------
function Copy-ToTarget {
    param(
        [string]$TargetTableName,
        [System.Data.DataTable]$Data,
        [bool]$KeepIdentity = $true
    )

    if ($Data.Rows.Count -eq 0) {
        Write-Host "  $TargetTableName : 0 rows (source empty)"
        return
    }

    $conn = Open-SqlConnection -ConnectionString $TargetConnectionString
    try {
        $options = [Microsoft.Data.SqlClient.SqlBulkCopyOptions]::TableLock
        if ($KeepIdentity) {
            $options = $options -bor [Microsoft.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity
        }

        $bulk = [Microsoft.Data.SqlClient.SqlBulkCopy]::new($conn, $options, $null)
        $bulk.DestinationTableName = $TargetTableName
        $bulk.BulkCopyTimeout = $BulkCopyTimeout
        $bulk.BatchSize = 5000

        foreach ($col in $Data.Columns) {
            [void]$bulk.ColumnMappings.Add($col.ColumnName, $col.ColumnName)
        }

        $bulk.WriteToServer($Data)
        Write-Host "  $TargetTableName : $($Data.Rows.Count) rows copied"
    }
    finally {
        $conn.Close()
        $conn.Dispose()
    }
}

# ===========================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " ARA Production Data Copy"
Write-Host "============================================================"
Write-Host ""
if (-not [string]::IsNullOrWhiteSpace($SourceServer)) {
    Write-Host " Source: $SourceServer / $SourceDatabase"
} else {
    Write-Host " Source: (provided connection string)"
}
if (-not [string]::IsNullOrWhiteSpace($TargetServer)) {
    Write-Host " Target: $TargetServer / $TargetDatabase"
} else {
    Write-Host " Target: (provided connection string)"
}
if ($SkipBinaryAttachments) {
    Write-Host " Mode:   Skipping attachment binary data"
}
Write-Host ""

# ===========================================================================
# PHASE 1 — Validate connectivity
# ===========================================================================
Write-Host "PHASE 1: Validating connectivity..."

try {
    $srcConn = Open-SqlConnection -ConnectionString $SourceConnectionString
    $srcConn.Close()
    $srcConn.Dispose()
    Write-Host "  Source connection: OK"
}
catch {
    Write-Error "Cannot connect to source database: $($_.Exception.Message)"
}

try {
    $tgtConn = Open-SqlConnection -ConnectionString $TargetConnectionString
    $tgtConn.Close()
    $tgtConn.Dispose()
    Write-Host "  Target connection: OK"
}
catch {
    Write-Error "Cannot connect to target database: $($_.Exception.Message)"
}

$existingTables = Invoke-SqlScalar -ConnectionString $TargetConnectionString `
    -Sql "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"

if ($existingTables -gt 0) {
    Write-Host "  WARNING: Target database has $existingTables existing tables."
    Write-Host "  Dropping all existing tables to start clean..."

    $dropOrder = @(
        'ara_export_archive', 'logbook', 'emailLog', 'attachments',
        'araAppList', 'araAppLog', 'clins', 'ara_con', 'ara_cm', 'ara_PM',
        'delegation', 'ara', 'users', 'thresholds',
        'Cat_Questions_Map', 'attach_checklist', 'emailTypes',
        'rejectionReason', 'customerType', 'revenueDescr', 'esReason',
        'status', 'category', 'jobTitle', 'sector', 'role'
    )

    foreach ($tbl in $dropOrder) {
        Invoke-Sql -ConnectionString $TargetConnectionString `
            -Sql "IF OBJECT_ID('dbo.[$tbl]', 'U') IS NOT NULL DROP TABLE dbo.[$tbl];"
    }
    Write-Host "  Existing tables dropped."
}

Write-Host "  Connectivity validated."

# ===========================================================================
# PHASE 2 — Create legacy tables (no foreign keys)
# ===========================================================================
Write-Host "`n============================================================"
Write-Host "PHASE 2: Creating legacy table schema..."
Write-Host "============================================================"

$createStatements = @(
    # --- Tier 1: No dependencies ---
    @{
        Name = 'role'
        Sql  = @"
CREATE TABLE dbo.[role] (
    ID_role   INT IDENTITY PRIMARY KEY,
    roleName  VARCHAR(50),
    roleShort VARCHAR(50),
    roleDesc  VARCHAR(200)
);
"@
    },
    @{
        Name = 'sector'
        Sql  = @"
CREATE TABLE dbo.sector (
    ID_sector  INT NOT NULL PRIMARY KEY,
    sectorName VARCHAR(50)
);
"@
    },
    @{
        Name = 'jobTitle'
        Sql  = @"
CREATE TABLE dbo.jobTitle (
    id_job      INT NOT NULL PRIMARY KEY,
    title       VARCHAR(100),
    description TEXT,
    appOrder    INT,
    inactive    BIT
);
"@
    },
    @{
        Name = 'category'
        Sql  = @"
CREATE TABLE dbo.category (
    id_cat    INT IDENTITY PRIMARY KEY,
    catName   VARCHAR(50),
    riskLevel INT,
    color     VARCHAR(50)
);
"@
    },
    @{
        Name = 'status'
        Sql  = @"
CREATE TABLE dbo.status (
    ID_status  INT IDENTITY PRIMARY KEY,
    statusName VARCHAR(75),
    OneWord    VARCHAR(50)
);
"@
    },
    @{
        Name = 'esReason'
        Sql  = @"
CREATE TABLE dbo.esReason (
    id_esReason INT IDENTITY PRIMARY KEY,
    reason      VARCHAR(50)
);
"@
    },
    @{
        Name = 'revenueDescr'
        Sql  = @"
CREATE TABLE dbo.revenueDescr (
    id_revenue INT IDENTITY PRIMARY KEY,
    Descr      VARCHAR(250)
);
"@
    },
    @{
        Name = 'customerType'
        Sql  = @"
CREATE TABLE dbo.customerType (
    id_customerType INT IDENTITY PRIMARY KEY,
    description     VARCHAR(50)
);
"@
    },
    @{
        Name = 'rejectionReason'
        Sql  = @"
CREATE TABLE dbo.rejectionReason (
    id_Reason INT IDENTITY PRIMARY KEY,
    reason    VARCHAR(100),
    Descr     VARCHAR(250)
);
"@
    },
    @{
        Name = 'emailTypes'
        Sql  = @"
CREATE TABLE dbo.emailTypes (
    id_emailtype     INT IDENTITY PRIMARY KEY,
    email_type       VARCHAR(50),
    long_description VARCHAR(255)
);
"@
    },
    @{
        Name = 'attach_checklist'
        Sql  = @"
CREATE TABLE dbo.attach_checklist (
    ID_attachtype  INT IDENTITY PRIMARY KEY,
    catID_List     VARCHAR(50),
    Short_desc     VARCHAR(60),
    Long_Desc      VARCHAR(500),
    display_order  INT,
    who            VARCHAR(50),
    status_Comment VARCHAR(100)
);
"@
    },
    @{
        Name = 'Cat_Questions_Map'
        Sql  = @"
CREATE TABLE dbo.Cat_Questions_Map (
    id_question   INT IDENTITY PRIMARY KEY,
    tab           VARCHAR(30),
    catID_list    VARCHAR(100),
    question      VARCHAR(255),
    ods_or_user   VARCHAR(20),
    tool_tip      VARCHAR(255),
    display_order INT,
    comment       VARCHAR(255)
);
"@
    },
    # --- Tier 2: Depends on tier 1 ---
    @{
        Name = 'thresholds'
        Sql  = @"
CREATE TABLE dbo.thresholds (
    id_threshold     INT IDENTITY PRIMARY KEY,
    riskLevel        INT,
    id_job           INT,
    low_thresh       INT,
    high_thresh      INT,
    review_approve   VARCHAR(20),
    delegate         INT,
    added_byoprid    VARCHAR(50),
    added_on         DATETIME,
    modified_byoprid VARCHAR(50),
    modified_on      DATETIME
);
"@
    },
    @{
        Name = 'users'
        Sql  = @"
CREATE TABLE dbo.users (
    id_user         INT IDENTITY PRIMARY KEY,
    emplID          VARCHAR(50),
    oprid           VARCHAR(50),
    password        VARCHAR(100),
    ID_group        INT,
    ID_sector       INT,
    ID_role         INT,
    ID_job          INT,
    empname         VARCHAR(500),
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    CostCenter      VARCHAR(50),
    Status          VARCHAR(20),
    Inactive        BIT,
    Approve_op      VARCHAR(50),
    Approve_div     VARCHAR(50),
    Approve_grp_OLD VARCHAR(100),
    Approve_grp     VARCHAR(500),
    created_by      INT,
    created_on      DATETIME,
    modified_by     INT,
    modified_on     DATETIME,
    ALNoprid        VARCHAR(50),
    email           VARCHAR(50),
    TSDEmail        VARCHAR(50)
);
"@
    },
    # --- Tier 3: Depends on users ---
    @{
        Name = 'ara'
        Sql  = @"
CREATE TABLE dbo.ara (
    id_ara             INT IDENTITY PRIMARY KEY,
    id_cat             INT,
    id_user            INT,
    id_status          INT,
    division           VARCHAR(50),
    reference          VARCHAR(50),
    revision           INT,
    title              VARCHAR(500),
    customerName       VARCHAR(500),
    contractNo         VARCHAR(50),
    doNo               VARCHAR(50),
    jamisNo            VARCHAR(50),
    contractType       VARCHAR(50),
    amountTotal        MONEY,
    amountRequested    MONEY,
    totalAnticipated   MONEY,
    percentAnticipated FLOAT,
    startDate          DATETIME,
    expirationDate     DATETIME,
    isEarlyStart       BIT,
    ID_esReason        INT,
    esOther            TEXT,
    OMSNum             VARCHAR(50),
    ID_Revenue         INT,
    ID_PM              INT,
    ID_Contract        INT,
    ID_Controller      INT,
    company            VARCHAR(10),
    isEAC              VARCHAR(5),
    ID_OpsVP           INT
);
"@
    },
    @{
        Name = 'delegation'
        Sql  = @"
CREATE TABLE dbo.delegation (
    id_delegation      INT IDENTITY PRIMARY KEY,
    fk_delegateFrom_ID INT,
    fk_delegateTo_ID   INT,
    delegateFrom_oprid VARCHAR(50),
    delegateTo_oprid   VARCHAR(50),
    startDate          DATETIME,
    endDate            DATETIME,
    dateadded          DATETIME,
    addedby            INT,
    datemodified       DATETIME,
    modifiedby         INT
);
"@
    },
    # --- Tier 4: Depends on ara ---
    @{
        Name = 'ara_PM'
        Sql  = @"
CREATE TABLE dbo.ara_PM (
    ara_PM_ID            INT IDENTITY PRIMARY KEY,
    ara_ID               INT NOT NULL,
    fundsInAdvance       TEXT,
    contractDefinization TEXT,
    pertinentInformation TEXT,
    workStarted          TEXT,
    consequence          TEXT,
    currentStatus        TEXT,
    changeInScope        TEXT,
    actionToClear        TEXT,
    ES_Necessary         TEXT,
    Other_necessary      TEXT
);
"@
    },
    @{
        Name = 'ara_cm'
        Sql  = @"
CREATE TABLE dbo.ara_cm (
    id_ara_cm                      INT IDENTITY PRIMARY KEY,
    id_ara                         INT,
    id_user                        INT,
    id_customerType                INT,
    contractType                   VARCHAR(50),
    authStart                      DATETIME,
    executionDate                  DATETIME,
    customerPO                     VARCHAR(50),
    POContactDate                  DATETIME,
    PCCostAuth                     MONEY,
    fundsToSupport                 INT,
    fundsExplanation               TEXT,
    creditCheck                    INT,
    creditExplanation              TEXT,
    allApprovals                   INT,
    allApprovalsExplanation        TEXT,
    forwarded                      INT,
    forwardedExplanation           TEXT,
    workAuthorization              INT,
    workAuthorizationExplanation   TEXT,
    authType                       VARCHAR(70),
    writtenConfirmation            INT,
    writtenConfirmationExplanation VARCHAR(70),
    alion_conf                     INT,
    Alion_confExplanation          VARCHAR(70),
    anticipatoryCost               INT,
    anticipatoryCostExplanation    VARCHAR(70),
    anticipatedNegotiation         DATETIME,
    CACertification                DATETIME,
    estModExeDate                  DATETIME,
    intClearCompDate               DATETIME,
    pop                            TEXT,
    poolAmt                        FLOAT,
    estFunDate                     DATETIME,
    pop2                           DATETIME
);
"@
    },
    @{
        Name = 'ara_con'
        Sql  = @"
CREATE TABLE dbo.ara_con (
    id_ara_con     INT IDENTITY PRIMARY KEY,
    id_ara         INT,
    id_user        INT,
    interestImpact FLOAT,
    burnRate       FLOAT,
    total_cost     FLOAT,
    total_fee      FLOAT,
    icCost         FLOAT,
    icFee          FLOAT,
    company        VARCHAR(10)
);
"@
    },
    @{
        Name = 'clins'
        Sql  = @"
CREATE TABLE dbo.clins (
    id_clins       INT IDENTITY PRIMARY KEY,
    id_ara         INT,
    clinNo         VARCHAR(50),
    description    TEXT,
    expirationDate DATETIME,
    revisionAmt    MONEY,
    costFunding    MONEY,
    feeFunding     MONEY,
    total          MONEY,
    CameFromJamis  INT,
    negate         VARCHAR(5) DEFAULT '0'
);
"@
    },
    @{
        Name = 'araAppLog'
        Sql  = @"
CREATE TABLE dbo.araAppLog (
    id_araAppLog       INT IDENTITY PRIMARY KEY,
    id_ara             INT,
    id_user            INT,
    id_job             INT,
    id_status          INT,
    isRejection        BIT,
    comment            TEXT,
    approvalDate       DATETIME,
    cycle              INT,
    id_reason          INT,
    Rej_areas          VARCHAR(100),
    oprid_delegateFrom VARCHAR(50),
    oprid_delegateTo   VARCHAR(50)
);
"@
    },
    @{
        Name = 'araAppList'
        Sql  = @"
CREATE TABLE dbo.araAppList (
    ID_araAppList          INT IDENTITY PRIMARY KEY,
    id_ara                 INT,
    programManager         INT,
    contractAdmin          INT,
    controller             INT,
    groupContractsManager  INT,
    groupController        INT,
    divisionManager        INT,
    operationManager       INT,
    groupManager           INT,
    sectorContractsManager INT,
    sectorController       INT,
    sectorManager          INT,
    cao                    INT,
    cfo                    INT,
    coo                    INT,
    ceo                    INT,
    cycle                  INT
);
"@
    },
    @{
        Name = 'attachments'
        Sql  = @"
CREATE TABLE dbo.attachments (
    id_attachment INT IDENTITY PRIMARY KEY,
    id_ara        INT,
    id_user       INT,
    filename      VARCHAR(100),
    fileType      VARCHAR(50),
    description   VARCHAR(255),
    [date]        DATETIME,
    Filesize      INT,
    MimeType      VARCHAR(100),
    binary_file   VARBINARY(MAX)
);
"@
    },
    @{
        Name = 'emailLog'
        Sql  = @"
CREATE TABLE dbo.emailLog (
    id_emailLog   INT IDENTITY PRIMARY KEY,
    id_ara        INT,
    id_emailType  INT,
    subject       TEXT,
    MsgTo         VARCHAR(500),
    MsgCC         VARCHAR(500),
    message_pdf   VARBINARY(MAX),
    sentDate      DATETIME DEFAULT GETDATE(),
    statusID      INT,
    id_araAppLog  INT,
    id_delegation INT
);
"@
    },
    @{
        Name = 'logbook'
        Sql  = @"
CREATE TABLE dbo.logbook (
    id_logbook INT IDENTITY PRIMARY KEY,
    id_user    INT,
    id_ara     INT,
    event      VARCHAR(500),
    url        VARCHAR(150),
    [timestamp] DATETIME DEFAULT GETDATE()
);
"@
    },
    @{
        Name = 'ara_export_archive'
        Sql  = @"
CREATE TABLE dbo.ara_export_archive (
    id_ara      INT,
    exported_dt DATETIME
);
"@
    }
)

foreach ($table in $createStatements) {
    Invoke-Sql -ConnectionString $TargetConnectionString -Sql $table.Sql
    Write-Host "  Created: $($table.Name)"
}

Write-Host "  All 26 tables created."

# ===========================================================================
# PHASE 3 — Copy data (dependency order)
# ===========================================================================
Write-Host "`n============================================================"
Write-Host "PHASE 3: Copying data..."
Write-Host "============================================================"

$tableResults = [ordered]@{}

$tablesToCopy = @(
    # Tier 1: No dependencies
    'role',
    'sector',
    'jobTitle',
    'category',
    'status',
    'esReason',
    'revenueDescr',
    'customerType',
    'rejectionReason',
    'emailTypes',
    'attach_checklist',
    'Cat_Questions_Map',
    # Tier 2: Depends on tier 1
    'thresholds',
    'users',
    # Tier 3: Depends on users
    'ara',
    'delegation',
    # Tier 4: Depends on ara
    'ara_PM',
    'ara_cm',
    'ara_con',
    'clins',
    'araAppLog',
    'araAppList',
    'attachments',
    'emailLog',
    'logbook',
    'ara_export_archive'
)

# Tables with identity columns that need IDENTITY_INSERT
$identityTables = @(
    'role', 'category', 'status', 'esReason', 'revenueDescr',
    'customerType', 'rejectionReason', 'emailTypes', 'thresholds',
    'attach_checklist', 'Cat_Questions_Map', 'users', 'ara',
    'delegation', 'ara_PM', 'ara_cm', 'ara_con', 'clins',
    'araAppLog', 'araAppList', 'attachments', 'emailLog', 'logbook'
)

# Tables without identity columns
$nonIdentityTables = @('sector', 'jobTitle', 'ara_export_archive')

foreach ($tableName in $tablesToCopy) {
    Write-Host "`nCopying $tableName ..."

    $hasIdentity = $tableName -notin $nonIdentityTables
    $quotedName = if ($tableName -eq 'role') { 'dbo.[role]' } else { "dbo.[$tableName]" }

    # Build SELECT query
    if ($tableName -eq 'attachments' -and $SkipBinaryAttachments) {
        $selectQuery = @"
SELECT
    id_attachment, id_ara, id_user, filename, fileType, description,
    [date], Filesize, MimeType, CAST(NULL AS VARBINARY(MAX)) AS binary_file
FROM dbo.attachments
"@
        Write-Host "  (skipping binary_file column)"
    }
    else {
        $selectQuery = "SELECT * FROM $quotedName"
    }

    $data = Read-Table -ConnectionString $SourceConnectionString -Query $selectQuery

    if ($hasIdentity) {
        Invoke-Sql -ConnectionString $TargetConnectionString `
            -Sql "SET IDENTITY_INSERT $quotedName ON;"
    }

    try {
        Copy-ToTarget -TargetTableName $quotedName -Data $data -KeepIdentity $hasIdentity
    }
    finally {
        if ($hasIdentity) {
            Invoke-Sql -ConnectionString $TargetConnectionString `
                -Sql "SET IDENTITY_INSERT $quotedName OFF;"
        }
    }

    $tableResults[$tableName] = $data.Rows.Count
}

# ===========================================================================
# PHASE 4 — Verify row counts
# ===========================================================================
Write-Host "`n============================================================"
Write-Host "PHASE 4: Verifying row counts..."
Write-Host "============================================================"

$mismatches = 0

foreach ($tableName in $tablesToCopy) {
    $quotedName = if ($tableName -eq 'role') { 'dbo.[role]' } else { "dbo.[$tableName]" }

    $sourceCount = Invoke-SqlScalar -ConnectionString $SourceConnectionString `
        -Sql "SELECT COUNT(*) FROM $quotedName"
    $targetCount = Invoke-SqlScalar -ConnectionString $TargetConnectionString `
        -Sql "SELECT COUNT(*) FROM $quotedName"

    $status = if ($sourceCount -eq $targetCount) { 'OK' } else { 'MISMATCH'; $mismatches++ }

    Write-Host ("  {0,-25} Source: {1,7}  Target: {2,7}  [{3}]" -f $tableName, $sourceCount, $targetCount, $status)
}

if ($mismatches -gt 0) {
    Write-Host "`n  WARNING: $mismatches table(s) have row count mismatches!" -ForegroundColor Yellow
}
else {
    Write-Host "`n  All row counts match."
}

# ===========================================================================
# PHASE 5 — Validate migration compatibility
# ===========================================================================
Write-Host "`n============================================================"
Write-Host "PHASE 5: Validating Invoke-AraDataMigration.ps1 compatibility..."
Write-Host "============================================================"
Write-Host "  Running each migration SELECT query against the copied data..."

$migrationQueries = [ordered]@{
    'role'               = "SELECT ID_role, roleName, roleShort, roleDesc FROM dbo.[role]"
    'sector'             = "SELECT ID_sector, sectorName FROM dbo.sector"
    'jobTitle'           = "SELECT id_job, title, CAST(description AS NVARCHAR(MAX)) AS description, appOrder, ISNULL(inactive, 0) AS inactive FROM dbo.jobTitle"
    'category'           = "SELECT id_cat, catName, riskLevel, color FROM dbo.category"
    'status'             = "SELECT ID_status, statusName, OneWord FROM dbo.status"
    'esReason'           = "SELECT id_esReason, reason FROM dbo.esReason"
    'revenueDescr'       = "SELECT id_revenue, Descr FROM dbo.revenueDescr"
    'customerType'       = "SELECT id_customerType, description FROM dbo.customerType"
    'rejectionReason'    = "SELECT id_Reason, reason, Descr FROM dbo.rejectionReason"
    'emailTypes'         = "SELECT id_emailtype, email_type, long_description FROM dbo.emailTypes"
    'thresholds'         = "SELECT id_threshold, riskLevel, id_job, low_thresh, high_thresh, review_approve, delegate FROM dbo.thresholds"
    'attach_checklist'   = "SELECT ID_attachtype, catID_List, Short_desc, Long_Desc, display_order, who, status_Comment FROM dbo.attach_checklist"
    'Cat_Questions_Map'  = "SELECT id_question, tab, catID_list, question, ods_or_user, tool_tip, display_order, comment FROM dbo.Cat_Questions_Map"
    'users'              = @"
SELECT
    id_user,
    ISNULL(oprid, 'legacy-user-' + CAST(id_user AS VARCHAR(20))) AS EntraObjectId,
    emplID,
    oprid AS LegacyOprid,
    ISNULL(empname, 'Unknown') AS DisplayName,
    first_name,
    last_name,
    email,
    ISNULL(ID_role, 1) AS RoleId,
    ID_job,
    ID_sector,
    Approve_grp,
    Approve_op,
    Approve_div,
    ISNULL(Inactive, 0) AS IsInactive,
    ISNULL(created_on, GETUTCDATE()) AS CreatedAt,
    modified_on AS UpdatedAt
FROM dbo.users
"@
    'ara'                = @"
SELECT
    id_ara,
    id_cat,
    id_status,
    id_user,
    ID_PM,
    ID_Contract,
    ID_Controller,
    ID_OpsVP,
    reference,
    ISNULL(revision, 0) AS revision,
    jamisNo,
    division,
    contractNo,
    doNo,
    contractType,
    OMSNum,
    title,
    customerName,
    ISNULL(amountTotal, 0) AS amountTotal,
    amountRequested,
    totalAnticipated,
    percentAnticipated,
    ID_Revenue,
    ISNULL(isEarlyStart, 0) AS isEarlyStart,
    ID_esReason,
    CAST(esOther AS NVARCHAR(MAX)) AS esOther,
    company,
    isEAC,
    startDate,
    expirationDate
FROM dbo.ara
"@
    'ara_PM'             = @"
SELECT
    ara_PM_ID,
    ara_ID,
    CAST(fundsInAdvance AS NVARCHAR(MAX)) AS fundsInAdvance,
    CAST(contractDefinization AS NVARCHAR(MAX)) AS contractDefinization,
    CAST(pertinentInformation AS NVARCHAR(MAX)) AS pertinentInformation,
    CAST(workStarted AS NVARCHAR(MAX)) AS workStarted,
    CAST(consequence AS NVARCHAR(MAX)) AS consequence,
    CAST(currentStatus AS NVARCHAR(MAX)) AS currentStatus,
    CAST(changeInScope AS NVARCHAR(MAX)) AS changeInScope,
    CAST(actionToClear AS NVARCHAR(MAX)) AS actionToClear,
    CAST(ES_Necessary AS NVARCHAR(MAX)) AS ES_Necessary,
    CAST(Other_necessary AS NVARCHAR(MAX)) AS Other_necessary
FROM dbo.ara_PM
"@
    'ara_cm'             = @"
SELECT
    id_ara_cm,
    id_ara,
    id_user,
    id_customerType,
    contractType,
    authStart,
    executionDate,
    customerPO,
    POContactDate,
    PCCostAuth,
    fundsToSupport,
    CAST(fundsExplanation AS NVARCHAR(MAX)) AS fundsExplanation,
    creditCheck,
    CAST(creditExplanation AS NVARCHAR(MAX)) AS creditExplanation,
    allApprovals,
    CAST(allApprovalsExplanation AS NVARCHAR(MAX)) AS allApprovalsExplanation,
    forwarded,
    CAST(forwardedExplanation AS NVARCHAR(MAX)) AS forwardedExplanation,
    workAuthorization,
    CAST(workAuthorizationExplanation AS NVARCHAR(MAX)) AS workAuthorizationExplanation,
    authType,
    writtenConfirmation,
    writtenConfirmationExplanation,
    alion_conf,
    Alion_confExplanation,
    anticipatoryCost,
    anticipatoryCostExplanation,
    anticipatedNegotiation,
    CACertification,
    estModExeDate,
    intClearCompDate,
    CAST(pop AS NVARCHAR(MAX)) AS pop,
    poolAmt,
    estFunDate,
    pop2
FROM dbo.ara_cm
"@
    'ara_con'            = "SELECT id_ara_con, id_ara, id_user, interestImpact, burnRate, total_cost, total_fee, icCost, icFee, company FROM dbo.ara_con"
    'clins'              = @"
SELECT
    id_clins,
    id_ara,
    clinNo,
    CAST(description AS NVARCHAR(MAX)) AS description,
    expirationDate,
    revisionAmt,
    costFunding,
    feeFunding,
    total,
    CAST(ISNULL(CameFromJamis, 0) AS BIT) AS CameFromJamis,
    CASE WHEN ISNULL(negate, '0') IN ('1', 'true', 'True') THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsNegated
FROM dbo.clins
"@
    'araAppLog'          = @"
SELECT
    id_araAppLog,
    id_ara,
    id_user,
    id_job,
    id_status,
    isRejection,
    CAST(comment AS NVARCHAR(MAX)) AS comment,
    approvalDate,
    cycle,
    id_reason,
    Rej_areas
FROM dbo.araAppLog
"@
    'araAppList'         = @"
SELECT
    ID_araAppList,
    id_ara,
    programManager,
    contractAdmin,
    controller,
    groupContractsManager,
    groupController,
    divisionManager,
    operationManager,
    groupManager,
    sectorContractsManager,
    sectorController,
    sectorManager,
    cao,
    cfo,
    coo,
    ceo,
    cycle
FROM dbo.araAppList
"@
    'attachments'        = @"
SELECT
    id_attachment,
    id_ara,
    id_user,
    ISNULL(filename, 'unknown.pdf') AS filename,
    '/legacy-migration/' + CAST(id_attachment AS VARCHAR(20)) + '/' + ISNULL(filename, 'unknown.pdf') AS StoragePath,
    Filesize,
    MimeType,
    ISNULL([date], GETUTCDATE()) AS UploadedAt,
    binary_file
FROM dbo.attachments
"@
    'delegation'         = @"
SELECT
    id_delegation,
    fk_delegateFrom_ID,
    fk_delegateTo_ID,
    delegateFrom_oprid,
    delegateTo_oprid,
    startDate,
    endDate,
    dateadded,
    addedby,
    datemodified,
    modifiedby
FROM dbo.delegation
"@
    'emailLog'           = @"
SELECT
    id_emailLog,
    id_ara,
    id_emailType,
    CAST(subject AS NVARCHAR(MAX)) AS subject,
    MsgTo,
    MsgCC,
    ISNULL(sentDate, GETUTCDATE()) AS sentDate,
    statusID,
    id_araAppLog
FROM dbo.emailLog
"@
    'logbook'            = @"
SELECT
    id_logbook,
    id_user,
    id_ara,
    event,
    url,
    ISNULL([timestamp], GETUTCDATE()) AS LoggedAt
FROM dbo.logbook
"@
    'ara_export_archive' = "SELECT id_ara, exported_dt FROM dbo.ara_export_archive"
}

$queryPasses = 0
$queryFailures = 0

foreach ($key in $migrationQueries.Keys) {
    try {
        $conn = Open-SqlConnection -ConnectionString $TargetConnectionString
        try {
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SET FMTONLY ON; $($migrationQueries[$key]); SET FMTONLY OFF;"
            $cmd.CommandTimeout = 30
            [void]$cmd.ExecuteNonQuery()
        }
        finally {
            $conn.Close()
            $conn.Dispose()
        }
        Write-Host "  $key : PASS"
        $queryPasses++
    }
    catch {
        Write-Host "  $key : FAIL - $($_.Exception.Message)" -ForegroundColor Red
        $queryFailures++
    }
}

Write-Host ""
if ($queryFailures -gt 0) {
    Write-Host "  $queryPasses passed, $queryFailures FAILED" -ForegroundColor Yellow
    Write-Host "  Fix failures before running Invoke-AraDataMigration.ps1" -ForegroundColor Yellow
}
else {
    Write-Host "  All $queryPasses migration queries validated successfully."
    Write-Host "  The copied database is ready for Invoke-AraDataMigration.ps1."
}

# ===========================================================================
# SUMMARY
# ===========================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " Copy Complete"
Write-Host "============================================================"
Write-Host ""
Write-Host " Table                     Rows"
Write-Host " -------------------------  ------"
foreach ($key in $tableResults.Keys) {
    Write-Host ("  {0,-25} {1,6}" -f $key, $tableResults[$key])
}
$totalRows = ($tableResults.Values | Measure-Object -Sum).Sum
Write-Host " -------------------------  ------"
Write-Host ("  {0,-25} {1,6}" -f 'TOTAL', $totalRows)
Write-Host ""
Write-Host "Row count verification:    $(if ($mismatches -eq 0) { 'ALL MATCH' } else { "$mismatches MISMATCH(ES)" })"
Write-Host "Migration compatibility:   $(if ($queryFailures -eq 0) { 'ALL PASS' } else { "$queryFailures FAILURE(S)" })"
Write-Host ""
if ($mismatches -eq 0 -and $queryFailures -eq 0) {
    Write-Host "NEXT STEP: Run the data migration:" -ForegroundColor Green
    Write-Host @"
  .\Invoke-AraDataMigration.ps1 ``
      -SourceConnectionString "Server=$TargetServer;Database=$TargetDatabase;User Id=$TargetUser;Password=<password>;" ``
      -TargetConnectionString "Server=<new-schema-server>;Database=<new-schema-db>;User Id=<user>;Password=<password>;"
"@ -ForegroundColor Green
}
Write-Host ""
