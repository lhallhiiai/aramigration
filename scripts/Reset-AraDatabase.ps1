<#
.SYNOPSIS
    Resets the ARA database to a clean development state.

.DESCRIPTION
    Drops all ARA tables (in FK-safe order), then re-runs the three
    migration scripts to recreate the schema, seed reference data, and
    deploy stored procedures. The result is a clean database with only
    the seed/lookup data and the dev user — no legacy or test data.

    This is the "factory reset" for local development. Run it any time
    you want a fresh start.

    Prerequisites:
      - Run 'az login' first (Azure AD token auth).
      - Requires the SqlServer PowerShell module (auto-installed if missing).

.PARAMETER ServerName
    Fully-qualified Azure SQL server host name.
    Default: hii-ara-dev-sql.database.windows.net

.PARAMETER DatabaseName
    Target database name.
    Default: hii-ara-dev-db

.PARAMETER ScriptsPath
    Directory containing the SQL migration scripts.
    Default: the sql\ subfolder alongside this script.

.PARAMETER SkipConfirmation
    Bypass the confirmation prompt. Use in automated pipelines.

.EXAMPLE
    .\Reset-AraDatabase.ps1
    Prompts for confirmation, then resets the default dev database.

.EXAMPLE
    .\Reset-AraDatabase.ps1 -SkipConfirmation
    Resets without prompting.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ServerName = 'hii-ara-dev-sql.database.windows.net',

    [Parameter()]
    [string]$DatabaseName = 'hii-ara-dev-db',

    [Parameter()]
    [string]$ScriptsPath = (Join-Path $PSScriptRoot 'sql'),

    [Parameter()]
    [switch]$SkipConfirmation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Confirmation gate
# ---------------------------------------------------------------------------
if (-not $SkipConfirmation) {
    Write-Host ""
    Write-Host "WARNING: This will DROP all ARA tables and recreate them from scratch." -ForegroundColor Yellow
    Write-Host "  Server  : $ServerName"
    Write-Host "  Database: $DatabaseName"
    Write-Host ""
    $answer = Read-Host "Type 'yes' to continue"
    if ($answer -ne 'yes') {
        Write-Host "Aborted."
        return
    }
}

# ---------------------------------------------------------------------------
# Ensure SqlServer module is available
# ---------------------------------------------------------------------------
if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    Write-Host "SqlServer PowerShell module not found. Installing for current user..."
    Install-Module -Name SqlServer -Force -AllowClobber -Scope CurrentUser
}

Import-Module SqlServer -ErrorAction Stop

# ---------------------------------------------------------------------------
# Obtain an Azure AD access token for Azure SQL
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Acquiring Azure AD access token for Azure SQL..."
$tokenJson = az account get-access-token --resource https://database.windows.net/ 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to acquire Azure AD token. Ensure you are logged in: 'az login'"
}
$accessToken = ($tokenJson | ConvertFrom-Json).accessToken
if ([string]::IsNullOrWhiteSpace($accessToken)) {
    Write-Error "Azure AD token was empty. Ensure you are logged in: 'az login'"
}
Write-Host "Token acquired successfully."

# ---------------------------------------------------------------------------
# Helper: run a SQL statement against the target database
# ---------------------------------------------------------------------------
function Invoke-Sql {
    param([string]$Query)
    Invoke-Sqlcmd `
        -ServerInstance $ServerName `
        -Database       $DatabaseName `
        -AccessToken    $accessToken `
        -Query          $Query `
        -QueryTimeout   120 `
        -ErrorAction    Stop
}

# ---------------------------------------------------------------------------
# STEP 1 — Drop all ARA tables in FK-safe order
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host " Step 1: Dropping all ARA tables"
Write-Host "============================================================"

# Tables listed in reverse FK-dependency order.
# Views and functions that reference tables are dropped first.
$dropOrder = @(
    # Dependent / child tables
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
    # Main table
    'Ara',
    # User table
    'User',
    # Lookup tables (no FKs point TO these from outside the set)
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

foreach ($tbl in $dropOrder) {
    $quoted = "dbo.[$tbl]"
    Invoke-Sql -Query "IF OBJECT_ID('$quoted', 'U') IS NOT NULL DROP TABLE $quoted;"
    Write-Host "  Dropped $quoted"
}

Write-Host "  All tables dropped."

# ---------------------------------------------------------------------------
# STEP 2 — Drop stored procedures (so they can be cleanly recreated)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host " Step 2: Dropping stored procedures"
Write-Host "============================================================"

$dropSpSql = @"
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += 'DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.procedures
WHERE SCHEMA_NAME(schema_id) = 'dbo'
  AND name LIKE 'usp_%';
IF LEN(@sql) > 0 EXEC sp_executesql @sql;
"@

Invoke-Sql -Query $dropSpSql
Write-Host "  All usp_* stored procedures dropped."

# ---------------------------------------------------------------------------
# STEP 3 — Recreate schema, seed data, and stored procedures
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host " Step 3: Recreating schema, seed data, and stored procedures"
Write-Host "============================================================"

$scripts = @(
    '001_tables.sql',
    '002_seed_data.sql',
    '003_stored_procedures.sql'
)

foreach ($script in $scripts) {
    $scriptFile = Join-Path $ScriptsPath $script

    if (-not (Test-Path $scriptFile)) {
        Write-Error "Migration script not found: $scriptFile"
    }

    Write-Host ""
    Write-Host "  Running $script ..."

    Invoke-Sqlcmd `
        -ServerInstance $ServerName `
        -Database       $DatabaseName `
        -AccessToken    $accessToken `
        -InputFile      $scriptFile `
        -QueryTimeout   120 `
        -ErrorAction    Stop

    Write-Host "  Completed: $script"
}

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================"
Write-Host " Reset Complete"
Write-Host "============================================================"
Write-Host ""
Write-Host "The database has been reset to a clean development state:"
Write-Host "  - All tables recreated from 001_tables.sql"
Write-Host "  - Reference/lookup data seeded from 002_seed_data.sql"
Write-Host "  - Stored procedures deployed from 003_stored_procedures.sql"
Write-Host "  - Dev user (dev-user-00000000 / dev@local.dev) is ready"
Write-Host ""
