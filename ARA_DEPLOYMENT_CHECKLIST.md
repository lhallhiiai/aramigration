# ARA Application - On-Premises Deployment Checklist

**Target Environment:** Windows Server 2019 or 2022 with IIS  
**Last Updated:** 2026-05-11

This checklist covers all prerequisites, configuration files, and commands needed to deploy the ARA application on a development or production machine.

---

## Table of Contents

1. [Third-Party Tools & Prerequisites](#1-third-party-tools--prerequisites)
2. [Configuration Files to Update](#2-configuration-files-to-update)
3. [Database Setup](#3-database-setup)
4. [Backend Deployment](#4-backend-deployment)
5. [Frontend Deployment](#5-frontend-deployment)
6. [Verification Commands](#6-verification-commands)

---

## 1. Third-Party Tools & Prerequisites

### 1.1 Server Software Requirements

**Operating System:**
- Windows Server 2019 or Windows Server 2022

**IIS (Internet Information Services):**
```powershell
# Install IIS with required features
Install-WindowsFeature -Name Web-Server, Web-Mgmt-Console, Web-Asp-Net45 -IncludeManagementTools
```

**ASP.NET Core Hosting Bundle (.NET 10):**
- Download from: https://dotnet.microsoft.com/download/dotnet/10.0
- Install the "Hosting Bundle" (includes runtime + IIS module)
- Verify installation:
```powershell
& "$env:ProgramFiles\dotnet\dotnet.exe" --list-runtimes
# Should show: Microsoft.AspNetCore.App 10.x
```

**SQL Server Client:**
- Microsoft.Data.SqlClient (included in app dependencies)
- Ensure outbound connectivity to Azure SQL MI on port 1433

---

### 1.2 Development Tools (for building the application)

**Backend Build Tools:**
- .NET 10 SDK
  - Download: https://dotnet.microsoft.com/download/dotnet/10.0
  - Verify: `dotnet --version` (should show 10.x)

**Frontend Build Tools:**
- Node.js (v18 or later recommended)
  - Download: https://nodejs.org/
  - Verify: `node --version`
- npm (comes with Node.js)
  - Verify: `npm --version`

**Source Control:**
- Git (optional, for cloning repository)

---

### 1.3 External Service Dependencies

**Okta (Authentication):**
- Okta tenant URL (test or production)
- Okta API application configured with:
  - Client ID
  - Issuer URL
  - Audience (typically `api://default`)

**Azure SQL Managed Instance:**
- SQL Server hostname and port (typically `:1433`)
- Database name: `ara_new`
- SQL Authentication credentials (username/password)

**Application Insights (Optional - Telemetry):**
- Azure Application Insights connection string
- If not provided, telemetry is disabled

**SMTP Email Server (Optional):**
- SMTP host and port (e.g., `smtp.office365.com:587`)
- From address (e.g., `ara@hii-tsd.com`)
- If not configured, emails are logged to database only

---

### 1.4 SSL/TLS Certificate

**Internal CA Certificate:**
- Certificate for your hostname (e.g., `ara.hii-tsd.com` or `aradev.hii-tsd.com`)
- Must be imported to `LocalMachine\My` certificate store with private key
- Capture the certificate thumbprint (40-character hex string)

**Import Certificate:**
```powershell
# Import PFX with private key
$pfxPath = "C:\path\to\certificate.pfx"
$pfxPassword = Read-Host "Enter PFX password" -AsSecureString
Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation Cert:\LocalMachine\My -Password $pfxPassword

# Get thumbprint
Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*ara*" } | Select-Object Thumbprint, Subject, NotAfter
```

---

## 2. Configuration Files to Update

### 2.1 Backend Configuration

**File:** `backend/src/ARA.Api/appsettings.Production.json`

⚠️ **IMPORTANT:** This file is NOT tracked in git. It must be created from the template during deployment.

**Template File:** `backend/src/ARA.Api/appsettings.Production.json.example`

**Required Configuration Values:**

```json
{
  "AllowedOrigins": [
    "https://ara.hii-tsd.com"  // ← Update with your actual hostname
  ],
  "Okta": {
    "Issuer": "https://hii-test.oktapreview.com/oauth2/default",  // ← Your Okta issuer URL
    "Audience": "api://default"  // ← Your Okta audience
  },
  "ConnectionStrings": {
    "AraDatabase": "Server=tcp:<sql-host>,1433;Database=ara_new;User ID=<username>;Password=<password>;Encrypt=True;"
  },
  "ApplicationInsights": {
    "ConnectionString": "<app-insights-connection-string-or-empty>"
  },
  "Email": {
    "FromAddress": "ara@hii-tsd.com",  // ← Your from address
    "Smtp": {
      "Host": "smtp.office365.com",  // ← Your SMTP host (or empty)
      "Port": 587,  // ← Your SMTP port
      "SecureSocketOptions": "Auto"  // Options: None, Auto, SslOnConnect, StartTls, StartTlsWhenAvailable
    }
  }
}
```

**Security Note:** The installer script (`Install-AraOnPremises.ps1`) will automatically:
1. Generate this file from the template
2. Set restrictive NTFS ACLs (read for app pool identity + Administrators only)

---

### 2.2 Frontend Configuration

**File:** `.env.local` (for local development) or build-time environment variables (for production)

**Template File:** `frontend/.env.example`

**Required Environment Variables:**

```bash
VITE_OKTA_ISSUER=https://hii-test.oktapreview.com/oauth2/default
VITE_OKTA_CLIENT_ID=<your-okta-client-id>
VITE_API_BASE=https://ara.hii-tsd.com  # Production: full hostname; Dev: can use proxy
```

**For Local Development:**
```powershell
# Copy template and edit
cd frontend
Copy-Item .env.example .env.local
# Edit .env.local with your values
```

**For Production Build:**
```powershell
# Set environment variables before build
$env:VITE_OKTA_ISSUER = "https://hii-test.oktapreview.com/oauth2/default"
$env:VITE_OKTA_CLIENT_ID = "<your-client-id>"
$env:VITE_API_BASE = "https://ara.hii-tsd.com"
npm run build
```

---

## 3. Database Setup

### 3.1 Database Migration Scripts

The database schema is created and seeded using SQL migration scripts located in `scripts/sql/`:

**Migration Script Order:**
1. `001_tables.sql` - Creates all database tables
2. `002_seed_data.sql` - Populates lookup/reference tables
3. `003_stored_procedures.sql` - Creates stored procedures
4. `004_rename_entra_column.sql` - Schema update (if needed)

### 3.2 Running Database Migrations

**Option A: Using PowerShell Helper Script**
```powershell
# Run all migrations in order
.\scripts\Invoke-AraMigration.ps1 -ConnectionString "Server=tcp:<host>,1433;Database=ara_new;User ID=<user>;Password=<pass>;Encrypt=True;"
```

**Option B: Manual Execution via SSMS**
```powershell
# Connect to Azure SQL MI with SQL Server Management Studio
# Execute scripts in order:
# 1. Open and run 001_tables.sql
# 2. Open and run 002_seed_data.sql
# 3. Open and run 003_stored_procedures.sql
# 4. Open and run 004_rename_entra_column.sql (if applicable)
```

**Option C: Using sqlcmd**
```powershell
$server = "<sql-host>"
$database = "ara_new"
$username = "<username>"
$password = "<password>"

sqlcmd -S $server -d $database -U $username -P $password -i "scripts\sql\001_tables.sql"
sqlcmd -S $server -d $database -U $username -P $password -i "scripts\sql\002_seed_data.sql"
sqlcmd -S $server -d $database -U $username -P $password -i "scripts\sql\003_stored_procedures.sql"
sqlcmd -S $server -d $database -U $username -P $password -i "scripts\sql\004_rename_entra_column.sql"
```

### 3.3 Historical Data Migration (Production Only)

If migrating from legacy ARA database:

```powershell
.\scripts\Invoke-AraDataMigration.ps1 `
    -SourceConnectionString "Server=<legacy-server>;Database=<legacy-db>;..." `
    -TargetConnectionString "Server=tcp:<new-host>,1433;Database=ara_new;..."
```

---

## 4. Backend Deployment

### 4.1 Build Backend

```powershell
# Navigate to backend API project
cd new\backend\src\ARA.Api

# Restore dependencies
dotnet restore

# Build in Release mode
dotnet build --configuration Release

# Publish to output folder
dotnet publish --configuration Release --output C:\Staging\ARA-Backend
```

### 4.2 Create Deployment Package

```powershell
# Compress publish output to ZIP
Compress-Archive -Path C:\Staging\ARA-Backend\* -DestinationPath C:\Staging\ARA-Publish.zip -Force
```

### 4.3 Deploy to IIS Using Installer Script

The `Install-AraOnPremises.ps1` script automates the IIS deployment:

```powershell
.\scripts\Install-AraOnPremises.ps1 `
    -PublishBundlePath "C:\Staging\ARA-Publish.zip" `
    -SiteHostname "ara.hii-tsd.com" `
    -CertThumbprint "<40-char-thumbprint>" `
    -SqlConnectionString "Server=tcp:<host>,1433;Database=ara_new;User ID=<user>;Password=<pass>;Encrypt=True;" `
    -OktaIssuer "https://hii-test.oktapreview.com/oauth2/default" `
    -OktaAudience "api://default" `
    -AppInsightsConnectionString "<connection-string-or-empty>" `
    -AllowedOrigin "https://ara.hii-tsd.com" `
    -SmtpHost "smtp.office365.com" `
    -SmtpPort 587 `
    -SmtpFromAddress "ara@hii-tsd.com"
```

**What the installer does:**
1. Validates Windows Server version (2019 or 2022)
2. Checks IIS and ASP.NET Core Hosting Bundle
3. Extracts publish bundle to install path (default: `C:\inetpub\sites\ARA`)
4. Generates `appsettings.Production.json` from template
5. Sets restrictive NTFS ACLs on config file
6. Creates/updates IIS app pool and site
7. Binds HTTPS:443 to the specified certificate

---

## 5. Frontend Deployment

### 5.1 Build Frontend

```powershell
# Navigate to frontend project
cd new\frontend

# Install dependencies
npm install

# Set production environment variables
$env:VITE_OKTA_ISSUER = "https://hii-test.oktapreview.com/oauth2/default"
$env:VITE_OKTA_CLIENT_ID = "<your-okta-client-id>"
$env:VITE_API_BASE = "https://ara.hii-tsd.com"

# Build for production
npm run build
```

The build output will be in `new\frontend\dist\`

### 5.2 Deploy Frontend to IIS

The frontend is served from the same IIS site as the backend:

```powershell
# Copy frontend build to IIS site root
$frontendDist = "C:\git\aramigration\new\frontend\dist"
$iisSiteRoot = "C:\inetpub\sites\ARA"

# Copy all frontend files to site root
Copy-Item -Path "$frontendDist\*" -Destination $iisSiteRoot -Recurse -Force
```

**IIS Configuration:**
- `/` → Serves SPA static files (index.html, assets, etc.)
- `/api/*` → Proxied to backend ASP.NET Core app
- `/health/*` → Health check endpoints from backend

---

## 6. Verification Commands

### 6.1 Pre-Deployment Network Connectivity Tests

Run these from the server before deploying to ensure outbound connectivity:

```powershell
# Test Azure SQL MI connectivity
Test-NetConnection -ComputerName "<sql-host>" -Port 1433

# Test Okta connectivity
Test-NetConnection -ComputerName "hii-test.oktapreview.com" -Port 443

# Test Application Insights connectivity (if using)
Test-NetConnection -ComputerName "dc.services.visualstudio.com" -Port 443

# Test SMTP connectivity (if using)
Test-NetConnection -ComputerName "smtp.office365.com" -Port 587
```

All tests should return `TcpTestSucceeded : True`

---

### 6.2 Post-Deployment Health Checks

After deployment, verify the application is running:

```powershell
# Test liveness endpoint (basic health check)
Invoke-WebRequest -Uri "https://ara.hii-tsd.com/health/live" -SkipCertificateCheck
# Expected: 200 OK with empty body

# Test readiness endpoint (checks SQL, Okta, etc.)
Invoke-WebRequest -Uri "https://ara.hii-tsd.com/health/ready" -SkipCertificateCheck
# Expected: 200 OK with JSON body showing all checks as "Healthy"
```

### 6.3 IIS Application Pool Status

```powershell
# Check app pool is running
Import-Module WebAdministration
Get-WebAppPoolState -Name "ARA"
# Expected: Value = "Started"

# View app pool identity
Get-ItemProperty IIS:\AppPools\ARA -Name processModel.identityType
Get-ItemProperty IIS:\AppPools\ARA -Name processModel.userName
```

### 6.4 Database Connectivity Test

```powershell
# Test SQL connection from PowerShell
$connectionString = "Server=tcp:<host>,1433;Database=ara_new;User ID=<user>;Password=<pass>;Encrypt=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
try {
    $connection.Open()
    Write-Host "✓ Database connection successful" -ForegroundColor Green
    $connection.Close()
} catch {
    Write-Host "✗ Database connection failed: $_" -ForegroundColor Red
}
```

---

## Summary: Complete Deployment Sequence

1. **Install prerequisites** (IIS, .NET 10 Hosting Bundle, certificate)
2. **Run network connectivity tests** (SQL, Okta, SMTP, App Insights)
3. **Create and seed database** (run migration scripts)
4. **Build backend** (`dotnet publish`)
5. **Run installer script** (`Install-AraOnPremises.ps1`)
6. **Build frontend** (`npm run build` with env vars)
7. **Copy frontend to IIS site root**
8. **Verify health endpoints** (`/health/live`, `/health/ready`)
9. **Test application** (sign in, create test ARA)

---

## Additional Resources

- **Full deployment runbook:** `docs/ship/ON_PREM_DEPLOYMENT.md`
- **Install checklist:** `docs/ship/INSTALL_AND_VERIFY_CHECKLIST.md`
- **TLS/networking guide:** `docs/ship/TLS_AND_NETWORKING.md`
- **Installer script:** `scripts/Install-AraOnPremises.ps1`
