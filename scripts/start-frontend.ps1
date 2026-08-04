#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Starts the ARA frontend development server.

.DESCRIPTION
    Launches the Vite dev server on http://localhost:5173 with API proxy to backend.
    Can be run from any directory - automatically finds repository root.

.EXAMPLE
    .\start-frontend.ps1
    # Or from anywhere:
    C:\git\aramigration\scripts\start-frontend.ps1
#>

# Find repository root (works from any directory)
# If script is in the repo, use git from current location
# Otherwise, use the script's location to find the repo
Push-Location $PSScriptRoot
$repoRoot = git rev-parse --show-toplevel 2>$null
Pop-Location

if (-not $repoRoot) {
    Write-Host "Error: Could not find git repository. Please ensure the script is in the aramigration repository." -ForegroundColor Red
    exit 1
}
$repoRoot = $repoRoot -replace '/', '\'

# Navigate to frontend directory
Set-Location "$repoRoot\new\frontend"

# Install dependencies if needed
Write-Host "`nInstalling dependencies..." -ForegroundColor Cyan
npm ci

# Start the dev server
Write-Host "`nStarting ARA Frontend Dev Server..." -ForegroundColor Green
Write-Host "URL: http://localhost:5173" -ForegroundColor Yellow
Write-Host "API Proxy: /api -> http://localhost:5081" -ForegroundColor Yellow
Write-Host "`nPress Ctrl+C to stop the dev server`n" -ForegroundColor Cyan

npm run dev
