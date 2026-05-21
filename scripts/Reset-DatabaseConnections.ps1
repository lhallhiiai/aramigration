<#
.SYNOPSIS
    Forcefully closes all connections to the database and resets it.

.DESCRIPTION
    Sets the database to single-user mode (kicking out all other connections),
    then immediately sets it back to multi-user mode. This is useful when
    migrations are hung due to blocking locks.

.PARAMETER ConnectionString
    Full connection string for the database.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module SqlServer -ErrorAction Stop

# Extract database name from connection string
if ($ConnectionString -match 'Database=([^;]+)') {
    $dbName = $matches[1]
} else {
    throw "Could not parse database name from connection string"
}

Write-Host "`nForcing database '$dbName' to reset connections...`n" -ForegroundColor Cyan
Write-Warning "This will kill all active connections to the database!"

$confirm = Read-Host "Type 'yes' to confirm"
if ($confirm -ne 'yes') {
    Write-Host "`nAborted.`n" -ForegroundColor Yellow
    exit 0
}

try {
    # Change to master database to run these commands
    $masterConnString = $ConnectionString -replace "Database=$dbName", "Database=master"
    
    Write-Host "Setting database to single-user mode (with immediate rollback)..." -ForegroundColor Yellow
    
    $sql = @"
ALTER DATABASE [$dbName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE [$dbName] SET MULTI_USER;
"@
    
    Invoke-Sqlcmd -ConnectionString $masterConnString -Query $sql -QueryTimeout 60
    
    Write-Host "`n✓ Database connections reset successfully." -ForegroundColor Green
    Write-Host "  All blocking sessions have been terminated." -ForegroundColor Green
    Write-Host "`nYou can now restart the migration.`n" -ForegroundColor Cyan
    
} catch {
    Write-Host "`n✗ Error: $_`n" -ForegroundColor Red
    exit 1
}
