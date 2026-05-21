<#
.SYNOPSIS
    Test exact column names in target User table and compare with mappings.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetConnectionString
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module SqlServer -ErrorAction Stop

Write-Host "`nChecking target User table columns...`n" -ForegroundColor Cyan

# Get exact column names from target table
$query = @"
SELECT name AS ColumnName
FROM sys.columns
WHERE object_id = OBJECT_ID('dbo.[User]')
ORDER BY column_id;
"@

try {
    $targetColumns = Invoke-Sqlcmd -ConnectionString $TargetConnectionString -Query $query -QueryTimeout 30
    
    Write-Host "Target table columns:" -ForegroundColor Yellow
    $targetColumnNames = @()
    foreach ($col in $targetColumns) {
        Write-Host "  - $($col.ColumnName)" -ForegroundColor White
        $targetColumnNames += $col.ColumnName
    }
    
    Write-Host "`nExpected destination mappings:" -ForegroundColor Yellow
    $expectedTargets = @(
        'UserId', 'EntraObjectId', 'EmployeeId', 'LegacyOprid', 'DisplayName',
        'FirstName', 'LastName', 'Email', 'RoleId', 'JobTitleId', 'SectorId',
        'ApprovalGroups', 'ApprovalOperation', 'ApprovalDivision',
        'IsInactive', 'CreatedAt', 'UpdatedAt'
    )
    
    Write-Host "`nValidation:" -ForegroundColor Yellow
    $allGood = $true
    foreach ($expected in $expectedTargets) {
        if ($targetColumnNames -contains $expected) {
            Write-Host "  ✓ '$expected'" -ForegroundColor Green
        } else {
            Write-Host "  ✗ '$expected' MISSING!" -ForegroundColor Red
            $allGood = $false
        }
    }
    
    Write-Host "`nExtra columns in target table:" -ForegroundColor Yellow
    foreach ($actual in $targetColumnNames) {
        if ($expectedTargets -notcontains $actual) {
            Write-Host "  + '$actual' (not in mapping)" -ForegroundColor Cyan
        }
    }
    
    if ($allGood) {
        Write-Host "`n✓ All expected columns exist in target table." -ForegroundColor Green
    } else {
        Write-Host "`n✗ Some columns are missing in target table!" -ForegroundColor Red
    }
    
} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    
    # Check if table exists
    $tableCheck = @"
SELECT COUNT(*) AS TableExists
FROM sys.tables
WHERE name = 'User' AND schema_id = SCHEMA_ID('dbo');
"@
    
    $exists = Invoke-Sqlcmd -ConnectionString $TargetConnectionString -Query $tableCheck -QueryTimeout 30
    if ($exists.TableExists -eq 0) {
        Write-Host "`nTable dbo.[User] does not exist!" -ForegroundColor Red
    }
    
    exit 1
}
