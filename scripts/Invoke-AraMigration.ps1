<#
.SYNOPSIS
    Runs the ARA database migration scripts against a SQL database.

.DESCRIPTION
    Executes the three idempotent migration scripts in order:
      001_tables.sql          – creates or verifies all tables
      002_seed_data.sql       – loads reference / lookup data
      003_stored_procedures.sql – creates or alters all stored procedures

    Authentication options:
      - ConnectionString parameter: Use any valid SQL connection string
        (SQL Auth, Windows Auth, etc.) — no Azure CLI needed.
      - ServerName + DatabaseName (default): Uses Azure AD Default
        (Managed Identity in Azure; your logged-in az CLI account locally).
        Run 'az login' first.

    Requires the SqlServer PowerShell module. The script installs it for
    the current user automatically if it is not already present.

.PARAMETER ConnectionString
    Full connection string for the target database. When provided,
    ServerName and DatabaseName are ignored and no Azure AD token is acquired.
    Example: "Server=localhost;Database=ARA_New;Integrated Security=True;TrustServerCertificate=True;"
    Example: "Server=myserver;Database=ARA_New;User Id=sa;Password=MyPass;TrustServerCertificate=True;"

.PARAMETER ServerName
    Fully-qualified Azure SQL server host name.
    Default: hii-ara-dev-sql.database.windows.net
    Ignored when ConnectionString is provided.

.PARAMETER DatabaseName
    Target database name.
    Default: hii-ara-dev-db
    Ignored when ConnectionString is provided.

.PARAMETER ScriptsPath
    Directory containing the three SQL migration scripts.
    Default: the sql\ subfolder alongside this script.

.EXAMPLE
    .\Invoke-AraMigration.ps1
    Runs all three scripts against the default Azure SQL dev database.

.EXAMPLE
    .\Invoke-AraMigration.ps1 -ConnectionString "Server=localhost;Database=ARA_New;Integrated Security=True;TrustServerCertificate=True;"
    Runs all three scripts against a local SQL Server using Windows Auth.

.EXAMPLE
    .\Invoke-AraMigration.ps1 -ConnectionString "Server=myserver;Database=ARA_New;User Id=sa;Password=MyPass;TrustServerCertificate=True;"
    Runs all three scripts against a SQL Server using SQL Auth.

.EXAMPLE
    .\Invoke-AraMigration.ps1 -ScriptsPath 'C:\custom\sql'
    Runs scripts from a custom directory.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConnectionString,

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
# Determine authentication mode
# ---------------------------------------------------------------------------
$useConnectionString = -not [string]::IsNullOrWhiteSpace($ConnectionString)
$accessToken = $null

if ($useConnectionString) {
    Write-Host "Using provided connection string (no Azure AD token)."
}
else {
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
}

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
    if ($useConnectionString) {
        Write-Host "  Connection: (provided connection string)"
    }
    else {
        Write-Host "  Server  : $ServerName"
        Write-Host "  Database: $DatabaseName"
    }
    Write-Host "  File    : $scriptFile"

    if ($useConnectionString) {
        Invoke-Sqlcmd `
            -ConnectionString $ConnectionString `
            -InputFile        $scriptFile `
            -QueryTimeout     120 `
            -ErrorAction      Stop
    }
    else {
        Invoke-Sqlcmd `
            -ServerInstance $ServerName `
            -Database       $DatabaseName `
            -AccessToken    $accessToken `
            -InputFile      $scriptFile `
            -QueryTimeout   120 `
            -ErrorAction    Stop
    }

    Write-Host "  Completed: $script"
}

Write-Host ""
Write-Host "All migration scripts completed successfully."
