<#
.SYNOPSIS
    Finds and kills blocking sessions in the database.

.DESCRIPTION
    Identifies active sessions that might be blocking operations and provides
    options to kill them. Useful when a migration gets stuck due to locks.

.PARAMETER ConnectionString
    Full connection string for the database.

.PARAMETER KillAll
    Automatically kill all blocking sessions without prompting.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString,

    [Parameter()]
    [switch]$KillAll
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module SqlServer -ErrorAction Stop

Write-Host "`nChecking for active sessions and blocks...`n" -ForegroundColor Cyan

# Query to find all active sessions
$query = @"
SELECT 
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    s.status,
    r.command,
    r.wait_type,
    r.wait_time,
    r.blocking_session_id,
    SUBSTRING(
        qt.text,
        (r.statement_start_offset/2) + 1,
        ((CASE r.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE r.statement_end_offset
        END - r.statement_start_offset)/2) + 1
    ) AS statement_text
FROM sys.dm_exec_sessions s
LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) qt
WHERE s.session_id > 50
  AND s.session_id <> @@SPID
ORDER BY s.session_id;
"@

try {
    $sessions = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $query -QueryTimeout 30
    
    if (-not $sessions) {
        Write-Host "No active sessions found (besides this one)." -ForegroundColor Green
        exit 0
    }
    
    Write-Host "Active sessions:" -ForegroundColor Yellow
    $sessions | Format-Table session_id, login_name, status, command, wait_type, wait_time, blocking_session_id -AutoSize
    
    # Find blocking sessions
    $blockers = $sessions | Where-Object { $_.blocking_session_id -gt 0 } | Select-Object -ExpandProperty blocking_session_id -Unique
    
    if ($blockers) {
        Write-Host "`nBlocking sessions detected:" -ForegroundColor Red
        foreach ($blocker in $blockers) {
            Write-Host "  Session ID: $blocker" -ForegroundColor Red
        }
        
        if ($KillAll) {
            Write-Host "`nKilling blocking sessions..." -ForegroundColor Yellow
            foreach ($blocker in $blockers) {
                try {
                    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query "KILL $blocker;" -QueryTimeout 10
                    Write-Host "  ✓ Killed session $blocker" -ForegroundColor Green
                } catch {
                    Write-Host "  ✗ Failed to kill session $blocker : $_" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "`nTo kill these sessions, run:" -ForegroundColor Yellow
            foreach ($blocker in $blockers) {
                Write-Host "  KILL $blocker;" -ForegroundColor White
            }
            Write-Host "`nOr rerun this script with -KillAll to kill them automatically." -ForegroundColor Yellow
        }
    }
    
    # Look for long-running sessions
    $longRunning = $sessions | Where-Object { $_.wait_time -gt 30000 }
    if ($longRunning) {
        Write-Host "`nLong-running sessions (waiting >30 seconds):" -ForegroundColor Yellow
        $longRunning | Format-Table session_id, login_name, command, wait_type, wait_time -AutoSize
    }
    
} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    exit 1
}
