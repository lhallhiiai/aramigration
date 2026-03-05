<#
.SYNOPSIS
    Migrates data from the legacy ARA database into the new PascalCase schema.

.DESCRIPTION
    Reads from the legacy ARA database (source) and writes into the new schema
    tables (target) using SqlBulkCopy for efficient cross-server data transfer.

    The script:
      1. Clears all target tables in reverse FK-dependency order
      2. Copies lookup/reference tables preserving original IDs
      3. Copies the Users table (oprid becomes placeholder EntraObjectId)
      4. Copies the main ARA table
      5. Copies all dependent tables (sections, CLINs, approvals, attachments, etc.)
      6. Adds a temporary LegacyBinaryFile column to AraAttachment for binary data

    Prerequisites:
      - New schema must already exist (run Invoke-AraMigration.ps1 first)
      - For Azure SQL target: run 'az login' first
      - Legacy source must be accessible via the provided connection string

.PARAMETER SourceConnectionString
    Full connection string for the legacy ARA database.
    Example: "Server=legacy-server;Database=ARA;Integrated Security=True;"

.PARAMETER TargetServer
    Fully-qualified Azure SQL server host name for the new database.
    Default: hii-ara-dev-sql.database.windows.net

.PARAMETER TargetDatabase
    Target database name.
    Default: hii-ara-dev-db

.PARAMETER TargetConnectionString
    Optional full connection string for the target database. When provided,
    TargetServer and TargetDatabase are ignored and no Azure AD token is acquired.
    Use this for local SQL Server or SQL auth targets.

.PARAMETER BulkCopyTimeout
    Timeout in seconds for each SqlBulkCopy operation. Default: 600 (10 minutes).

.EXAMPLE
    .\Invoke-AraDataMigration.ps1 -SourceConnectionString "Server=corpdb;Database=ARA;Integrated Security=True;"

.EXAMPLE
    .\Invoke-AraDataMigration.ps1 `
        -SourceConnectionString "Server=corpdb;Database=ARA;Integrated Security=True;" `
        -TargetConnectionString "Server=localhost;Database=hii-ara-dev-db;Integrated Security=True;"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceConnectionString,

    [Parameter()]
    [string]$TargetServer = 'hii-ara-dev-sql.database.windows.net',

    [Parameter()]
    [string]$TargetDatabase = 'hii-ara-dev-db',

    [Parameter()]
    [string]$TargetConnectionString,

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
# Build target connection string
# ---------------------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($TargetConnectionString)) {
    Write-Host "Acquiring Azure AD access token for Azure SQL..."
    $tokenJson = az account get-access-token --resource https://database.windows.net/ 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to acquire Azure AD token. Ensure you are logged in: 'az login'"
    }
    $script:TargetAccessToken = ($tokenJson | ConvertFrom-Json).accessToken
    if ([string]::IsNullOrWhiteSpace($script:TargetAccessToken)) {
        Write-Error "Azure AD token was empty. Ensure you are logged in: 'az login'"
    }
    $TargetConnectionString = "Server=$TargetServer;Database=$TargetDatabase;Encrypt=True;TrustServerCertificate=False;"
    Write-Host "Token acquired. Target: $TargetServer / $TargetDatabase"
}
else {
    $script:TargetAccessToken = $null
    Write-Host "Using provided target connection string (no Azure AD token)."
}

# ---------------------------------------------------------------------------
# Helper: Open a SqlConnection to the target, optionally with access token
# ---------------------------------------------------------------------------
function Open-TargetConnection {
    $conn = [Microsoft.Data.SqlClient.SqlConnection]::new($TargetConnectionString)
    if ($script:TargetAccessToken) {
        $conn.AccessToken = $script:TargetAccessToken
    }
    $conn.Open()
    return $conn
}

# ---------------------------------------------------------------------------
# Helper: Execute a non-query SQL statement on the target
# ---------------------------------------------------------------------------
function Invoke-TargetSql {
    param([string]$Sql)
    $conn = Open-TargetConnection
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $Sql
        $cmd.CommandTimeout = $BulkCopyTimeout
        [void]$cmd.ExecuteNonQuery()
    }
    finally {
        $conn.Close()
        $conn.Dispose()
    }
}

# ---------------------------------------------------------------------------
# Helper: Read a DataTable from the source database
# ---------------------------------------------------------------------------
function Read-SourceTable {
    param([string]$Query)
    $conn = [Microsoft.Data.SqlClient.SqlConnection]::new($SourceConnectionString)
    $conn.Open()
    try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $Query
        $cmd.CommandTimeout = $BulkCopyTimeout
        $reader = $cmd.ExecuteReader()
        $table = [System.Data.DataTable]::new()
        $table.Load($reader)
        return , $table
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
        [hashtable]$ColumnMappings,
        [bool]$KeepIdentity = $true
    )

    if ($Data.Rows.Count -eq 0) {
        Write-Host "  $TargetTableName : 0 rows (source empty)"
        return
    }

    $conn = Open-TargetConnection
    try {
        $options = [Microsoft.Data.SqlClient.SqlBulkCopyOptions]::TableLock
        if ($KeepIdentity) {
            $options = $options -bor [Microsoft.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity
        }

        $bulk = [Microsoft.Data.SqlClient.SqlBulkCopy]::new($conn, $options, $null)
        $bulk.DestinationTableName = $TargetTableName
        $bulk.BulkCopyTimeout = $BulkCopyTimeout
        $bulk.BatchSize = 5000

        foreach ($key in $ColumnMappings.Keys) {
            [void]$bulk.ColumnMappings.Add($key, $ColumnMappings[$key])
        }

        $bulk.WriteToServer($Data)
        Write-Host "  $TargetTableName : $($Data.Rows.Count) rows copied"
    }
    finally {
        $conn.Close()
        $conn.Dispose()
    }
}

# ---------------------------------------------------------------------------
# Helper: Migrate a single table end-to-end
# ---------------------------------------------------------------------------
function Migrate-Table {
    param(
        [string]$LegacyName,
        [string]$TargetName,
        [string]$SelectQuery,
        [hashtable]$ColumnMappings,
        [bool]$HasIdentity = $true,
        [bool]$KeepIdentity = $true
    )

    Write-Host "`nMigrating $LegacyName -> $TargetName ..."

    $data = Read-SourceTable -Query $SelectQuery

    if ($HasIdentity -and $KeepIdentity) {
        Invoke-TargetSql -Sql "SET IDENTITY_INSERT dbo.[$TargetName] ON;"
    }

    try {
        Copy-ToTarget -TargetTableName "dbo.[$TargetName]" -Data $data -ColumnMappings $ColumnMappings -KeepIdentity $KeepIdentity
    }
    finally {
        if ($HasIdentity -and $KeepIdentity) {
            Invoke-TargetSql -Sql "SET IDENTITY_INSERT dbo.[$TargetName] OFF;"
        }
    }

    return $data.Rows.Count
}

# ===========================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " ARA Legacy Data Migration"
Write-Host "============================================================"
Write-Host ""

$totalRows = 0
$tableResults = [ordered]@{}

# ===========================================================================
# PHASE 1 — Clear target tables (reverse FK-dependency order)
# ===========================================================================
Write-Host "PHASE 1: Clearing target tables..."

$clearOrder = @(
    'AraExportArchive',
    'AuditLog',
    'EmailLog',
    'AraAttachmentRequirementLink',
    'AraAttachment',
    'AraApprovalAssignment',
    'AraApprovalLog',
    'Clin',
    'AraControllerSection',
    'AraCaSection',
    'AraPmSection',
    'Delegation',
    'Ara',
    'User',
    'Threshold',
    'AttachmentRequirement',
    'QuestionMap',
    'EmailType',
    'RejectionReason',
    'CustomerType',
    'RevenueDescription',
    'EarlyStartReason',
    'Status',
    'Category',
    'JobTitle',
    'Sector',
    'Role'
)

foreach ($tbl in $clearOrder) {
    $quoted = if ($tbl -eq 'User') { 'dbo.[User]' } else { "dbo.[$tbl]" }
    Invoke-TargetSql -Sql "DELETE FROM $quoted;"
    Write-Host "  Cleared $quoted"
}

Write-Host "  All target tables cleared."

# ===========================================================================
# PHASE 2 — Lookup / reference tables
# ===========================================================================
Write-Host "`n============================================================"
Write-Host "PHASE 2: Migrating lookup / reference tables..."
Write-Host "============================================================"

# --- Role ---
$count = Migrate-Table -LegacyName 'role' -TargetName 'Role' `
    -SelectQuery "SELECT ID_role, roleName, roleShort, roleDesc FROM dbo.role" `
    -ColumnMappings @{
        'ID_role'   = 'RoleId'
        'roleName'  = 'RoleName'
        'roleShort' = 'RoleShort'
        'roleDesc'  = 'RoleDesc'
    }
$tableResults['Role'] = $count; $totalRows += $count

# --- Sector ---
$count = Migrate-Table -LegacyName 'sector' -TargetName 'Sector' `
    -SelectQuery "SELECT ID_sector, sectorName FROM dbo.sector" `
    -ColumnMappings @{
        'ID_sector'  = 'SectorId'
        'sectorName' = 'SectorName'
    } -HasIdentity $false
$tableResults['Sector'] = $count; $totalRows += $count

# --- JobTitle ---
$count = Migrate-Table -LegacyName 'jobTitle' -TargetName 'JobTitle' `
    -SelectQuery "SELECT id_job, title, CAST(description AS NVARCHAR(MAX)) AS description, appOrder, ISNULL(inactive, 0) AS inactive FROM dbo.jobTitle" `
    -ColumnMappings @{
        'id_job'      = 'JobTitleId'
        'title'       = 'Title'
        'description' = 'Description'
        'appOrder'    = 'AppOrder'
        'inactive'    = 'IsInactive'
    } -HasIdentity $false
$tableResults['JobTitle'] = $count; $totalRows += $count

# --- Category ---
$count = Migrate-Table -LegacyName 'category' -TargetName 'Category' `
    -SelectQuery "SELECT id_cat, catName, riskLevel, color FROM dbo.category" `
    -ColumnMappings @{
        'id_cat'    = 'CategoryId'
        'catName'   = 'CategoryName'
        'riskLevel' = 'RiskLevel'
        'color'     = 'Color'
    }
$tableResults['Category'] = $count; $totalRows += $count

# --- Status ---
$count = Migrate-Table -LegacyName 'status' -TargetName 'Status' `
    -SelectQuery "SELECT ID_status, statusName, OneWord FROM dbo.status" `
    -ColumnMappings @{
        'ID_status'  = 'StatusId'
        'statusName' = 'StatusName'
        'OneWord'    = 'OneWord'
    }
$tableResults['Status'] = $count; $totalRows += $count

# Print status IDs for verification
Write-Host "  ** Verifying legacy Status IDs:"
$statusData = Read-SourceTable -Query "SELECT ID_status, statusName FROM dbo.status ORDER BY ID_status"
foreach ($row in $statusData.Rows) {
    Write-Host "     StatusId=$($row['ID_status'])  Name=$($row['statusName'])"
}

# --- EarlyStartReason ---
$count = Migrate-Table -LegacyName 'esReason' -TargetName 'EarlyStartReason' `
    -SelectQuery "SELECT id_esReason, reason FROM dbo.esReason" `
    -ColumnMappings @{
        'id_esReason' = 'EarlyStartReasonId'
        'reason'      = 'Reason'
    }
$tableResults['EarlyStartReason'] = $count; $totalRows += $count

# --- RevenueDescription ---
$count = Migrate-Table -LegacyName 'revenueDescr' -TargetName 'RevenueDescription' `
    -SelectQuery "SELECT id_revenue, Descr FROM dbo.revenueDescr" `
    -ColumnMappings @{
        'id_revenue' = 'RevenueDescriptionId'
        'Descr'      = 'Description'
    }
$tableResults['RevenueDescription'] = $count; $totalRows += $count

# --- CustomerType ---
$count = Migrate-Table -LegacyName 'customerType' -TargetName 'CustomerType' `
    -SelectQuery "SELECT id_customerType, description FROM dbo.customerType" `
    -ColumnMappings @{
        'id_customerType' = 'CustomerTypeId'
        'description'     = 'Description'
    }
$tableResults['CustomerType'] = $count; $totalRows += $count

# --- RejectionReason ---
$count = Migrate-Table -LegacyName 'rejectionReason' -TargetName 'RejectionReason' `
    -SelectQuery "SELECT id_Reason, reason, Descr FROM dbo.rejectionReason" `
    -ColumnMappings @{
        'id_Reason' = 'RejectionReasonId'
        'reason'    = 'Reason'
        'Descr'     = 'Description'
    }
$tableResults['RejectionReason'] = $count; $totalRows += $count

# --- EmailType ---
$count = Migrate-Table -LegacyName 'emailTypes' -TargetName 'EmailType' `
    -SelectQuery "SELECT id_emailtype, email_type, long_description FROM dbo.emailTypes" `
    -ColumnMappings @{
        'id_emailtype'     = 'EmailTypeId'
        'email_type'       = 'EmailType'
        'long_description' = 'LongDescription'
    }
$tableResults['EmailType'] = $count; $totalRows += $count

# --- Threshold ---
$count = Migrate-Table -LegacyName 'thresholds' -TargetName 'Threshold' `
    -SelectQuery "SELECT id_threshold, riskLevel, id_job, low_thresh, high_thresh, review_approve, delegate FROM dbo.thresholds" `
    -ColumnMappings @{
        'id_threshold'   = 'ThresholdId'
        'riskLevel'      = 'RiskLevel'
        'id_job'         = 'JobTitleId'
        'low_thresh'     = 'LowThreshold'
        'high_thresh'    = 'HighThreshold'
        'review_approve' = 'ReviewApprove'
        'delegate'       = 'CanDelegate'
    }
$tableResults['Threshold'] = $count; $totalRows += $count

# --- AttachmentRequirement ---
$count = Migrate-Table -LegacyName 'attach_checklist' -TargetName 'AttachmentRequirement' `
    -SelectQuery "SELECT ID_attachtype, catID_List, Short_desc, Long_Desc, display_order, who, status_Comment FROM dbo.attach_checklist" `
    -ColumnMappings @{
        'ID_attachtype'  = 'AttachmentRequirementId'
        'catID_List'     = 'CategoryIdList'
        'Short_desc'     = 'ShortDescription'
        'Long_Desc'      = 'LongDescription'
        'display_order'  = 'DisplayOrder'
        'who'            = 'ApplicableRole'
        'status_Comment' = 'StatusComment'
    }
$tableResults['AttachmentRequirement'] = $count; $totalRows += $count

# --- QuestionMap ---
$count = Migrate-Table -LegacyName 'Cat_Questions_Map' -TargetName 'QuestionMap' `
    -SelectQuery "SELECT id_question, tab, catID_list, question, ods_or_user, tool_tip, display_order, comment FROM dbo.Cat_Questions_Map" `
    -ColumnMappings @{
        'id_question'  = 'QuestionMapId'
        'tab'          = 'Tab'
        'catID_list'   = 'CategoryIdList'
        'question'     = 'Question'
        'ods_or_user'  = 'SourceType'
        'tool_tip'     = 'ToolTip'
        'display_order'= 'DisplayOrder'
        'comment'      = 'Comment'
    }
$tableResults['QuestionMap'] = $count; $totalRows += $count

# ===========================================================================
# PHASE 3 — Users
# ===========================================================================
Write-Host "`n============================================================"
Write-Host "PHASE 3: Migrating users..."
Write-Host "============================================================"

$count = Migrate-Table -LegacyName 'users' -TargetName 'User' `
    -SelectQuery @"
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
"@ `
    -ColumnMappings @{
        'id_user'       = 'UserId'
        'EntraObjectId' = 'EntraObjectId'
        'emplID'        = 'EmployeeId'
        'LegacyOprid'   = 'LegacyOprid'
        'DisplayName'   = 'DisplayName'
        'first_name'    = 'FirstName'
        'last_name'     = 'LastName'
        'email'         = 'Email'
        'RoleId'        = 'RoleId'
        'ID_job'        = 'JobTitleId'
        'ID_sector'     = 'SectorId'
        'Approve_grp'   = 'ApprovalGroups'
        'Approve_op'    = 'ApprovalOperation'
        'Approve_div'   = 'ApprovalDivision'
        'IsInactive'    = 'IsInactive'
        'CreatedAt'     = 'CreatedAt'
        'UpdatedAt'     = 'UpdatedAt'
    }
$tableResults['User'] = $count; $totalRows += $count

# Insert dev user for local development
Write-Host "  Inserting dev user (dev-user-00000000)..."
Invoke-TargetSql -Sql @"
IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE EntraObjectId = N'dev-user-00000000')
BEGIN
    SET IDENTITY_INSERT dbo.[User] ON;
    DECLARE @maxId INT = (SELECT ISNULL(MAX(UserId), 0) + 1 FROM dbo.[User]);
    INSERT INTO dbo.[User] (UserId, EntraObjectId, DisplayName, FirstName, LastName, Email, RoleId, JobTitleId, IsInactive)
    VALUES (@maxId, N'dev-user-00000000', N'Dev User', N'Dev', N'User', N'dev@local.dev', 1, 1, 0);
    SET IDENTITY_INSERT dbo.[User] OFF;
END
"@
Write-Host "  Dev user ready."

# ===========================================================================
# PHASE 4 — Main ARA table
# ===========================================================================
Write-Host "`n============================================================"
Write-Host "PHASE 4: Migrating ARA records..."
Write-Host "============================================================"

$count = Migrate-Table -LegacyName 'ara' -TargetName 'Ara' `
    -SelectQuery @"
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
"@ `
    -ColumnMappings @{
        'id_ara'             = 'AraId'
        'id_cat'             = 'CategoryId'
        'id_status'          = 'StatusId'
        'id_user'            = 'CreatedByUserId'
        'ID_PM'              = 'ProgramManagerId'
        'ID_Contract'        = 'ContractAdministratorId'
        'ID_Controller'      = 'ControllerId'
        'ID_OpsVP'           = 'OpsVpUserId'
        'reference'          = 'Reference'
        'revision'           = 'Revision'
        'jamisNo'            = 'JamisId'
        'division'           = 'Division'
        'contractNo'         = 'ContractNumber'
        'doNo'               = 'DeliveryOrderNumber'
        'contractType'       = 'ContractType'
        'OMSNum'             = 'OmsNumber'
        'title'              = 'Title'
        'customerName'       = 'CustomerName'
        'amountTotal'        = 'AmountTotal'
        'amountRequested'    = 'AmountRequested'
        'totalAnticipated'   = 'TotalAnticipated'
        'percentAnticipated' = 'PercentAnticipated'
        'ID_Revenue'         = 'RevenueDescriptionId'
        'isEarlyStart'       = 'IsEarlyStart'
        'ID_esReason'        = 'EarlyStartReasonId'
        'esOther'            = 'EarlyStartReasonOther'
        'company'            = 'Company'
        'isEAC'              = 'IsEac'
        'startDate'          = 'StartDate'
        'expirationDate'     = 'ExpirationDate'
    }
$tableResults['Ara'] = $count; $totalRows += $count

# ===========================================================================
# PHASE 5 — Dependent tables
# ===========================================================================
Write-Host "`n============================================================"
Write-Host "PHASE 5: Migrating dependent tables..."
Write-Host "============================================================"

# --- AraPmSection ---
$count = Migrate-Table -LegacyName 'ara_PM' -TargetName 'AraPmSection' `
    -SelectQuery @"
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
"@ `
    -ColumnMappings @{
        'ara_PM_ID'            = 'AraPmSectionId'
        'ara_ID'               = 'AraId'
        'fundsInAdvance'       = 'FundsInAdvance'
        'contractDefinization' = 'ContractDefinization'
        'pertinentInformation' = 'PertinentInformation'
        'workStarted'          = 'WorkStarted'
        'consequence'          = 'Consequence'
        'currentStatus'        = 'CurrentStatus'
        'changeInScope'        = 'ChangeInScope'
        'actionToClear'        = 'ActionToClear'
        'ES_Necessary'         = 'EarlyStartNecessary'
        'Other_necessary'      = 'OtherNecessary'
    }
$tableResults['AraPmSection'] = $count; $totalRows += $count

# --- AraCaSection ---
$count = Migrate-Table -LegacyName 'ara_cm' -TargetName 'AraCaSection' `
    -SelectQuery @"
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
"@ `
    -ColumnMappings @{
        'id_ara_cm'                      = 'AraCaSectionId'
        'id_ara'                         = 'AraId'
        'id_user'                        = 'CaUserId'
        'id_customerType'                = 'CustomerTypeId'
        'contractType'                   = 'ContractType'
        'authStart'                      = 'AuthorizationStartDate'
        'executionDate'                  = 'ExecutionDate'
        'customerPO'                     = 'CustomerPo'
        'POContactDate'                  = 'PoContactDate'
        'PCCostAuth'                     = 'PcCostAuthorization'
        'fundsToSupport'                 = 'FundsToSupport'
        'fundsExplanation'               = 'FundsExplanation'
        'creditCheck'                    = 'CreditCheck'
        'creditExplanation'              = 'CreditExplanation'
        'allApprovals'                   = 'AllApprovals'
        'allApprovalsExplanation'        = 'AllApprovalsExplanation'
        'forwarded'                      = 'Forwarded'
        'forwardedExplanation'           = 'ForwardedExplanation'
        'workAuthorization'              = 'WorkAuthorization'
        'workAuthorizationExplanation'   = 'WorkAuthorizationExplanation'
        'authType'                       = 'AuthorizationType'
        'writtenConfirmation'            = 'WrittenConfirmation'
        'writtenConfirmationExplanation' = 'WrittenConfirmationExplanation'
        'alion_conf'                     = 'AlionConfirmation'
        'Alion_confExplanation'          = 'AlionConfirmationExplanation'
        'anticipatoryCost'               = 'AnticipatoryRisk'
        'anticipatoryCostExplanation'    = 'AnticipatoryRiskExplanation'
        'anticipatedNegotiation'         = 'AnticipatedNegotiationDate'
        'CACertification'                = 'CaCertificationDate'
        'estModExeDate'                  = 'EstimatedModificationExecDate'
        'intClearCompDate'               = 'InternalClearCompletionDate'
        'pop'                            = 'PeriodOfPerformance'
        'poolAmt'                        = 'PoolAmount'
        'estFunDate'                     = 'EstimatedFundingDate'
        'pop2'                           = 'PeriodOfPerformanceEnd'
    }
$tableResults['AraCaSection'] = $count; $totalRows += $count

# --- AraControllerSection ---
$count = Migrate-Table -LegacyName 'ara_con' -TargetName 'AraControllerSection' `
    -SelectQuery "SELECT id_ara_con, id_ara, id_user, interestImpact, burnRate, total_cost, total_fee, icCost, icFee, company FROM dbo.ara_con" `
    -ColumnMappings @{
        'id_ara_con'     = 'AraControllerSectionId'
        'id_ara'         = 'AraId'
        'id_user'        = 'ControllerId'
        'interestImpact' = 'InterestImpact'
        'burnRate'       = 'BurnRate'
        'total_cost'     = 'TotalCost'
        'total_fee'      = 'TotalFee'
        'icCost'         = 'IncurredCost'
        'icFee'          = 'IncurredFee'
        'company'        = 'Company'
    }
$tableResults['AraControllerSection'] = $count; $totalRows += $count

# --- Clin ---
$count = Migrate-Table -LegacyName 'clins' -TargetName 'Clin' `
    -SelectQuery @"
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
"@ `
    -ColumnMappings @{
        'id_clins'       = 'ClinId'
        'id_ara'         = 'AraId'
        'clinNo'         = 'ClinNumber'
        'description'    = 'Description'
        'expirationDate' = 'ExpirationDate'
        'revisionAmt'    = 'RevisionAmount'
        'costFunding'    = 'CostFunding'
        'feeFunding'     = 'FeeFunding'
        'total'          = 'Total'
        'CameFromJamis'  = 'CameFromJamis'
        'IsNegated'      = 'IsNegated'
    }
$tableResults['Clin'] = $count; $totalRows += $count

# --- AraApprovalLog ---
$count = Migrate-Table -LegacyName 'araAppLog' -TargetName 'AraApprovalLog' `
    -SelectQuery @"
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
"@ `
    -ColumnMappings @{
        'id_araAppLog' = 'AraApprovalLogId'
        'id_ara'       = 'AraId'
        'id_user'      = 'UserId'
        'id_job'       = 'JobTitleId'
        'id_status'    = 'StatusId'
        'isRejection'  = 'IsRejection'
        'comment'      = 'Comment'
        'approvalDate' = 'ActionDate'
        'cycle'        = 'Cycle'
        'id_reason'    = 'RejectionReasonId'
        'Rej_areas'    = 'RejectionAreas'
    }
$tableResults['AraApprovalLog'] = $count; $totalRows += $count

# --- AraApprovalAssignment ---
$count = Migrate-Table -LegacyName 'araAppList' -TargetName 'AraApprovalAssignment' `
    -SelectQuery @"
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
"@ `
    -ColumnMappings @{
        'ID_araAppList'         = 'AraApprovalAssignmentId'
        'id_ara'                = 'AraId'
        'programManager'        = 'ProgramManagerId'
        'contractAdmin'         = 'ContractAdminId'
        'controller'            = 'ControllerId'
        'groupContractsManager' = 'GroupContractsManagerId'
        'groupController'       = 'GroupControllerId'
        'divisionManager'       = 'DivisionManagerId'
        'operationManager'      = 'OperationManagerId'
        'groupManager'          = 'GroupManagerId'
        'sectorContractsManager'= 'SectorContractsMgrId'
        'sectorController'      = 'SectorControllerId'
        'sectorManager'         = 'SectorManagerId'
        'cao'                   = 'CaoId'
        'cfo'                   = 'CfoId'
        'coo'                   = 'CooId'
        'ceo'                   = 'CeoId'
        'cycle'                 = 'Cycle'
    }
$tableResults['AraApprovalAssignment'] = $count; $totalRows += $count

# --- AraAttachment (with binary) ---
Write-Host "`nMigrating attachments -> AraAttachment (with binary data)..."

# Add temporary column for binary data if it does not exist
Invoke-TargetSql -Sql @"
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.AraAttachment') AND name = 'LegacyBinaryFile'
)
BEGIN
    ALTER TABLE dbo.AraAttachment ADD LegacyBinaryFile VARBINARY(MAX) NULL;
END
"@
Write-Host "  LegacyBinaryFile column ensured on AraAttachment."

$count = Migrate-Table -LegacyName 'attachments' -TargetName 'AraAttachment' `
    -SelectQuery @"
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
"@ `
    -ColumnMappings @{
        'id_attachment' = 'AraAttachmentId'
        'id_ara'        = 'AraId'
        'id_user'       = 'UploadedByUserId'
        'filename'      = 'FileName'
        'StoragePath'   = 'StoragePath'
        'Filesize'      = 'FileSize'
        'MimeType'      = 'MimeType'
        'UploadedAt'    = 'UploadedAt'
        'binary_file'   = 'LegacyBinaryFile'
    }
$tableResults['AraAttachment'] = $count; $totalRows += $count

# --- Delegation ---
$count = Migrate-Table -LegacyName 'delegation' -TargetName 'Delegation' `
    -SelectQuery @"
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
"@ `
    -ColumnMappings @{
        'id_delegation'      = 'DelegationId'
        'fk_delegateFrom_ID' = 'DelegateFromId'
        'fk_delegateTo_ID'   = 'DelegateToId'
        'delegateFrom_oprid' = 'DelegateFromOprid'
        'delegateTo_oprid'   = 'DelegateToOprid'
        'startDate'          = 'StartDate'
        'endDate'            = 'EndDate'
        'dateadded'          = 'CreatedAt'
        'addedby'            = 'CreatedByUserId'
        'datemodified'       = 'UpdatedAt'
        'modifiedby'         = 'UpdatedByUserId'
    }
$tableResults['Delegation'] = $count; $totalRows += $count

# --- EmailLog ---
$count = Migrate-Table -LegacyName 'emailLog' -TargetName 'EmailLog' `
    -SelectQuery @"
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
"@ `
    -ColumnMappings @{
        'id_emailLog'  = 'EmailLogId'
        'id_ara'       = 'AraId'
        'id_emailType' = 'EmailTypeId'
        'subject'      = 'Subject'
        'MsgTo'        = 'Recipients'
        'MsgCC'        = 'CcRecipients'
        'sentDate'     = 'SentAt'
        'statusID'     = 'StatusId'
        'id_araAppLog' = 'AraApprovalLogId'
    }
$tableResults['EmailLog'] = $count; $totalRows += $count

# --- AuditLog ---
$count = Migrate-Table -LegacyName 'logbook' -TargetName 'AuditLog' `
    -SelectQuery @"
SELECT
    id_logbook,
    id_user,
    id_ara,
    event,
    url,
    ISNULL([timestamp], GETUTCDATE()) AS LoggedAt
FROM dbo.logbook
"@ `
    -ColumnMappings @{
        'id_logbook' = 'AuditLogId'
        'id_user'    = 'UserId'
        'id_ara'     = 'AraId'
        'event'      = 'Event'
        'url'        = 'Url'
        'LoggedAt'   = 'LoggedAt'
    }
$tableResults['AuditLog'] = $count; $totalRows += $count

# --- AraExportArchive ---
$count = Migrate-Table -LegacyName 'ara_export_archive' -TargetName 'AraExportArchive' `
    -SelectQuery "SELECT id_ara, exported_dt FROM dbo.ara_export_archive" `
    -ColumnMappings @{
        'id_ara'      = 'AraId'
        'exported_dt' = 'ExportedAt'
    } -KeepIdentity $false
$tableResults['AraExportArchive'] = $count; $totalRows += $count

# ===========================================================================
# SUMMARY
# ===========================================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " Migration Complete"
Write-Host "============================================================"
Write-Host ""
Write-Host " Table                        Rows"
Write-Host " ----------------------------  ------"
foreach ($key in $tableResults.Keys) {
    Write-Host ("  {0,-28} {1,6}" -f $key, $tableResults[$key])
}
Write-Host " ----------------------------  ------"
Write-Host ("  {0,-28} {1,6}" -f 'TOTAL', $totalRows)
Write-Host ""
Write-Host "IMPORTANT:"
Write-Host "  - Legacy Status IDs were preserved as-is. Verify they match"
Write-Host "    the AraStatus enum in ARA.Domain before running the app."
Write-Host "  - Attachment binaries are stored in AraAttachment.LegacyBinaryFile."
Write-Host "    A follow-up script is needed to upload to Azure Blob Storage,"
Write-Host "    update StoragePath, and then drop the LegacyBinaryFile column."
Write-Host "  - User.EntraObjectId was set to the legacy oprid value as a"
Write-Host "    placeholder. Update with real Entra OIDs before production use."
Write-Host "  - A dev user (dev-user-00000000) was inserted for local development."
Write-Host ""
