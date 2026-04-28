<#
.SYNOPSIS
    Parses a Cobertura coverage XML and fails if the overall line-rate is
    below the supplied threshold.

.DESCRIPTION
    Used by the PR-validation workflow to gate on backend coverage. Today
    the threshold is set conservatively at the level achievable on dev
    without merging the phase2 IEmailService work and without an Azure SQL
    test target in CI. Item 7 carry-forward in docs/SHIP_PLAN.md tracks
    raising the threshold once those gaps close.

.PARAMETER Path
    Path to the merged Cobertura XML report.

.PARAMETER MinimumLineRate
    Minimum acceptable line-rate as a fraction (0.0 - 1.0). Default 0.35.

.EXAMPLE
    ./scripts/Test-CoverageThreshold.ps1 -Path new/backend/CoverageReport/Cobertura.xml -MinimumLineRate 0.35
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [double]$MinimumLineRate = 0.35
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Path)) {
    Write-Error "Coverage report not found: $Path"
    exit 1
}

[xml]$report = Get-Content -Raw -Path $Path
$lineRate = [double]$report.coverage.'line-rate'
$linesCovered = [int]$report.coverage.'lines-covered'
$linesValid = [int]$report.coverage.'lines-valid'

$pct = '{0:P2}' -f $lineRate
$minPct = '{0:P2}' -f $MinimumLineRate

Write-Host "Line coverage: $pct ($linesCovered / $linesValid)"
Write-Host "Threshold:     $minPct"

if ($lineRate -lt $MinimumLineRate) {
    Write-Error "Coverage $pct is below the configured minimum $minPct."
    exit 1
}

Write-Host 'PASS: coverage is at or above the configured minimum.'
