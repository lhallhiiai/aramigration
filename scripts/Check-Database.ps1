<#
.SYNOPSIS
    Diagnostic script to check what tables and columns exist in the ARA database.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "`nChecking database schema...`n" -ForegroundColor Cyan

# Query to list all tables
$tablesQuery = @"
SELECT 
    t.name AS TableName,
    s.name AS SchemaName
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'dbo'
ORDER BY t.name;
"@

# Query to check Role table structure
$roleTableQuery = @"
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable,
    c.is_identity AS IsIdentity
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.Role')
ORDER BY c.column_id;
"@

try {
    # Import SqlServer module
    Import-Module SqlServer -ErrorAction Stop

    Write-Host "Tables in database:" -ForegroundColor Yellow
    $tables = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $tablesQuery -QueryTimeout 30
    
    if ($tables) {
        $tables | Format-Table -AutoSize
    } else {
        Write-Host "  No tables found." -ForegroundColor Red
    }

    Write-Host "`nRole table structure:" -ForegroundColor Yellow
    $roleColumns = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $roleTableQuery -QueryTimeout 30
    
    if ($roleColumns) {
        $roleColumns | Format-Table -AutoSize
    } else {
        Write-Host "  Role table does not exist." -ForegroundColor Red
    }

} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    exit 1
}
