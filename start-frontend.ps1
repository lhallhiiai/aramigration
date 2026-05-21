#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Starts the ARA frontend development server.

.DESCRIPTION
    Launches the Vite dev server on http://localhost:5173 with API proxy to backend.

.EXAMPLE
    .\start-frontend.ps1
#>

# Navigate to frontend directory
Set-Location "$PSScriptRoot\new\frontend"

# Start the dev server
Write-Host "`nStarting ARA Frontend Dev Server..." -ForegroundColor Green
Write-Host "URL: http://localhost:5173" -ForegroundColor Yellow
Write-Host "API Proxy: /api -> http://localhost:5081" -ForegroundColor Yellow
Write-Host "`nPress Ctrl+C to stop the dev server`n" -ForegroundColor Cyan

npm run dev
