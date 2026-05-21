#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Starts the ARA backend API in Development mode.

.DESCRIPTION
    Sets required environment variables and launches the API on http://localhost:5081.
    This script works around antivirus issues by running the DLL directly instead of using dotnet run.

.EXAMPLE
    .\start-backend.ps1
#>

# Set environment variables
$env:ASPNETCORE_ENVIRONMENT = "Development"
$env:ASPNETCORE_URLS = "http://localhost:5081"

# Navigate to backend directory
Set-Location "$PSScriptRoot\new\backend"

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

# Change to the API project directory where appsettings.json files live
Set-Location src\ARA.Api
dotnet bin\Debug\net10.0\ARA.Api.dll
