#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Starts the ARA backend API in Development mode.

.DESCRIPTION
    Sets required environment variables and launches the API on http://localhost:5081.
    This script works around antivirus issues by running the DLL directly instead of using dotnet run.
    Can be run from any directory - automatically finds repository root.

.EXAMPLE
    .\start-backend.ps1
    # Or from anywhere:
    C:\git\aramigration\scripts\start-backend.ps1
#>

# Set environment variables
$env:ASPNETCORE_ENVIRONMENT = "Development"
$env:ASPNETCORE_URLS = "http://localhost:5081"

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

# Navigate to backend directory (Join-Path produces OS-correct separators)
$backendDir = Join-Path $repoRoot "new" "backend"
Set-Location $backendDir

# Kill any existing instances
Write-Host "Checking for existing ARA.Api processes..." -ForegroundColor Cyan
Get-Process -Name "ARA.Api" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*aramigration*" } | Stop-Process -Force
Start-Sleep -Seconds 1

# Verify environment
Write-Host "`nEnvironment Variables:" -ForegroundColor Cyan
Write-Host "  ASPNETCORE_ENVIRONMENT = $env:ASPNETCORE_ENVIRONMENT" -ForegroundColor Gray
Write-Host "  ASPNETCORE_URLS = $env:ASPNETCORE_URLS" -ForegroundColor Gray

# Start the API from the project directory (not bin) so it finds appsettings correctly
Write-Host "`nStarting ARA Backend API..." -ForegroundColor Green
Write-Host "Environment: Development" -ForegroundColor Yellow
Write-Host "URL: http://localhost:5081" -ForegroundColor Yellow
Write-Host "`nPress Ctrl+C to stop the API`n" -ForegroundColor Cyan

# Build the project so the DLL exists
Write-Host "Building ARA.Api..." -ForegroundColor Cyan
dotnet build ARA.slnx --configuration Debug --nologo -v q
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed. Aborting." -ForegroundColor Red
    exit 1
}

# Change to the API project directory where appsettings.json files live
$apiDir = Join-Path $backendDir "src" "ARA.Api"
Set-Location $apiDir
dotnet "bin/Debug/net10.0/ARA.Api.dll"
