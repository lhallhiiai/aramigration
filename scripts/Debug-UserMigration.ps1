<#
.SYNOPSIS
    Debug script to test the users table query and see exact column names.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceConnectionString
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module SqlServer -ErrorAction Stop

$query = @"
WITH ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY oprid ORDER BY id_user) AS rn
    FROM dbo.users
)
SELECT TOP 1
    id_user,
    CASE
        WHEN oprid IS NULL THEN 'legacy-user-' + CAST(id_user AS VARCHAR(20))
        WHEN rn = 1       THEN oprid
        ELSE oprid + '-dup' + CAST(id_user AS VARCHAR(20))
    END AS EntraObjectId,
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
FROM ranked
"@

try {
    Write-Host "`nExecuting query and checking column names...`n" -ForegroundColor Cyan
    
    $conn = [Microsoft.Data.SqlClient.SqlConnection]::new($SourceConnectionString)
    $conn.Open()
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $query
    $reader = $cmd.ExecuteReader()
    $table = [System.Data.DataTable]::new()
    $table.Load($reader)
    
    Write-Host "Column names in DataTable:" -ForegroundColor Yellow
    foreach ($col in $table.Columns) {
        Write-Host "  '$($col.ColumnName)' -> $($col.DataType.Name)" -ForegroundColor White
    }
    
    Write-Host "`nExpected column mappings:" -ForegroundColor Yellow
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
    
    $columnNames = @($table.Columns | ForEach-Object { $_.ColumnName })
    
    Write-Host "`nValidating mappings:" -ForegroundColor Yellow
    foreach ($key in $mappings.Keys) {
        if ($columnNames -contains $key) {
            Write-Host "  ✓ '$key' exists" -ForegroundColor Green
        } else {
            Write-Host "  ✗ '$key' NOT FOUND in DataTable!" -ForegroundColor Red
        }
    }
    
    $conn.Close()
    
} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    exit 1
}
