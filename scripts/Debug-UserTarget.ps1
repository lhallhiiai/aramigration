<#
.SYNOPSIS
    Check the target User table structure.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetConnectionString
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module SqlServer -ErrorAction Stop

$query = @"
SELECT 
    c.name AS ColumnName,
    t.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable,
    c.is_identity AS IsIdentity
FROM sys.columns c
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.[User]')
ORDER BY c.column_id;
"@

try {
    Write-Host "`nTarget User table structure:`n" -ForegroundColor Cyan
    
    $columns = Invoke-Sqlcmd -ConnectionString $TargetConnectionString -Query $query -QueryTimeout 30
    $columns | Format-Table -AutoSize
    
    Write-Host "`nExpected destination column mappings:" -ForegroundColor Yellow
    $mappings = @{
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
    
    $targetColumns = @($columns | ForEach-Object { $_.ColumnName })
    
    Write-Host "`nValidating destination mappings:" -ForegroundColor Yellow
    foreach ($value in $mappings.Values) {
        if ($targetColumns -contains $value) {
            Write-Host "  ✓ '$value' exists" -ForegroundColor Green
        } else {
            Write-Host "  ✗ '$value' NOT FOUND in target table!" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    exit 1
}
