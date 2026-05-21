<#
.SYNOPSIS
    Drops all tables, views, stored procedures, and functions from the ARA database.

.DESCRIPTION
    Cleans the database completely to prepare for a fresh schema migration.
    This is useful when you need to start over from scratch.

.PARAMETER ConnectionString
    Full connection string for the target database.

.EXAMPLE
    .\scripts\Clean-Database.ps1 -ConnectionString "Server=localhost;Database=ARA;Integrated Security=True;"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Import SqlServer module
$localModulesDir = Join-Path $HOME '.psmodules'
if ($env:PSModulePath -notlike "*$localModulesDir*") {
    $env:PSModulePath = "$localModulesDir$([IO.Path]::PathSeparator)$env:PSModulePath"
}
Import-Module SqlServer -ErrorAction Stop

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host " Cleaning ARA Database" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Warning "This will drop ALL tables, views, stored procedures, and functions."
$confirm = Read-Host "Type 'yes' to confirm"

if ($confirm -ne 'yes') {
    Write-Host "`nAborted. No changes made.`n" -ForegroundColor Yellow
    exit 0
}

$cleanScript = @"
-- Disable all constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- Drop all foreign key constraints
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + 
               ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
FROM sys.foreign_keys;
EXEC sp_executesql @sql;

-- Drop all tables
SET @sql = '';
SELECT @sql += 'DROP TABLE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.tables;
EXEC sp_executesql @sql;

-- Drop all views
SET @sql = '';
SELECT @sql += 'DROP VIEW ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.views
WHERE is_ms_shipped = 0;
EXEC sp_executesql @sql;

-- Drop all stored procedures
SET @sql = '';
SELECT @sql += 'DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.procedures
WHERE is_ms_shipped = 0;
EXEC sp_executesql @sql;

-- Drop all functions
SET @sql = '';
SELECT @sql += 'DROP FUNCTION ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF', 'FS', 'FT')
  AND is_ms_shipped = 0;
EXEC sp_executesql @sql;

PRINT 'Database cleaned successfully.';
"@

try {
    Write-Host "Dropping all database objects..." -ForegroundColor Yellow
    
    Invoke-Sqlcmd `
        -ConnectionString $ConnectionString `
        -Query $cleanScript `
        -QueryTimeout 120 `
        -ErrorAction Stop

    Write-Host "`n✓ Database cleaned successfully." -ForegroundColor Green
    Write-Host "`nYou can now run Invoke-AraMigration.ps1 to create the schema.`n" -ForegroundColor Cyan

} catch {
    Write-Host "`n✗ Error cleaning database: $_`n" -ForegroundColor Red
    exit 1
}
