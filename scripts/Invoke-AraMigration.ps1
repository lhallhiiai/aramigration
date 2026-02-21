<#
.SYNOPSIS
    Runs the ARA database migration scripts against the Azure SQL database.

.DESCRIPTION
    Executes the three idempotent migration scripts in order:
      001_tables.sql          – creates or verifies all tables
      002_seed_data.sql       – loads reference / lookup data
      003_stored_procedures.sql – creates or alters all stored procedures

    Authentication uses Azure AD Default (Managed Identity in Azure;
    your logged-in az CLI account locally). Run 'az login' first.

    Requires the SqlServer PowerShell module. The script installs it for
    the current user automatically if it is not already present.

.PARAMETER ServerName
    Fully-qualified Azure SQL server host name.
    Default: hii-ara-dev-sql.database.windows.net

.PARAMETER DatabaseName
    Target database name.
    Default: hii-ara-dev-db

.PARAMETER ScriptsPath
    Directory containing the three SQL migration scripts.
    Default: the sql\ subfolder alongside this script.

.EXAMPLE
    .\Invoke-AraMigration.ps1
    Runs all three scripts against the default dev database.

.EXAMPLE
    .\Invoke-AraMigration.ps1 -ScriptsPath 'C:\custom\sql'
    Runs scripts from a custom directory.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ServerName = 'hii-ara-dev-sql.database.windows.net',

    [Parameter()]
    [string]$DatabaseName = 'hii-ara-dev-db',

    [Parameter()]
    [string]$ScriptsPath = (Join-Path $PSScriptRoot 'sql')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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
# Run each migration script in order
# ---------------------------------------------------------------------------
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
    Write-Host "Running $script ..."
    Write-Host "  Server  : $ServerName"
    Write-Host "  Database: $DatabaseName"
    Write-Host "  File    : $scriptFile"

    Invoke-Sqlcmd `
        -ServerInstance $ServerName `
        -Database       $DatabaseName `
        -AccessToken    $accessToken `
        -InputFile      $scriptFile `
        -QueryTimeout   120 `
        -ErrorAction    Stop

    Write-Host "  Completed: $script"
}

Write-Host ""
Write-Host "All migration scripts completed successfully."
