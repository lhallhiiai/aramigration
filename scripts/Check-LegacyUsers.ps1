<#
.SYNOPSIS
    Check the structure of the legacy users table.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module SqlServer -ErrorAction Stop

Write-Host "`nChecking legacy users table structure...`n" -ForegroundColor Cyan

$query = @"
SELECT TOP 1 *
FROM dbo.users;
"@

$columnsQuery = @"
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.users')
ORDER BY c.column_id;
"@

try {
    Write-Host "Legacy users table columns:" -ForegroundColor Yellow
    $columns = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $columnsQuery -QueryTimeout 30
    $columns | Format-Table -AutoSize

    Write-Host "`nSample row:" -ForegroundColor Yellow
    $sample = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $query -QueryTimeout 30
    $sample | Format-List

} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    exit 1
}
