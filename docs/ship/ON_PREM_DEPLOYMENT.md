# ARA on-prem deployment

> **Branch 5 placeholder.** This file currently carries only the **Item 8a "Server prerequisites"** section. The Item 8c first-deploy runbook (architecture sketch, ordered install walkthrough, smoke list, rollback procedure) lands on a follow-up branch (`docs/on-prem-runbook`) and expands this file.

## Server prerequisites

Run these once on a fresh Windows Server box (2019 or 2022, per D9 of `docs/ship/ON_PREM_PIVOT_PLAN.md`) before invoking `scripts/Install-AraOnPremises.ps1`. Each step has an explicit verify.

All commands below assume an elevated (admin) PowerShell session.

### 1. IIS role + features

WS 2019 and WS 2022 use the same `Install-WindowsFeature` syntax for the IIS roles the ARA app needs.

**Install:**

```powershell
Install-WindowsFeature -Name `
    Web-Server, `
    Web-WebServer, `
    Web-Common-Http, `
    Web-Static-Content, `
    Web-Default-Doc, `
    Web-Dir-Browsing, `
    Web-Http-Errors, `
    Web-Http-Redirect, `
    Web-Http-Logging, `
    Web-Stat-Compression, `
    Web-Filtering, `
    Web-Mgmt-Console, `
    Web-Mgmt-Service `
    -IncludeManagementTools
```

**Verify:**

```powershell
Get-WindowsFeature -Name Web-Server, Web-Mgmt-Console |
    Where-Object InstallState -ne "Installed"
# Expect zero rows. Any row returned = a missing role; re-run the install command.

Import-Module WebAdministration
Get-Item IIS:\Sites\Default*  # confirms the IIS provider is loaded
```

WS 2019 vs WS 2022: identical so far. If a future divergence appears, the install script's `Test-Prerequisites` step checks for the `WebAdministration` module on both.

### 2. ASP.NET Core 10 Hosting Bundle

The ARA backend targets `net10.0`. The Hosting Bundle installs the .NET 10 runtime, the ASP.NET Core runtime, and the IIS `AspNetCoreModuleV2` native module that lets IIS reverse-proxy to the in-process Kestrel host.

**Install:** download the latest **ASP.NET Core 10 Hosting Bundle** for Windows from <https://dotnet.microsoft.com/download/dotnet/10.0> and run the installer. Operators who want a silent install can use `dotnet-hosting-10.x.y-win.exe /install /quiet /norestart`.

**Verify:**

```powershell
& "$env:ProgramFiles\dotnet\dotnet.exe" --list-runtimes |
    Select-String "Microsoft.AspNetCore.App 10\."
# Expect at least one line, e.g. "Microsoft.AspNetCore.App 10.0.x [...]".

Test-Path "$env:SystemRoot\System32\inetsrv\aspnetcorev2.dll"
# Expect True.
```

WS 2019 vs WS 2022: identical. Both use the same Hosting Bundle installer.

### 3. App pool service account

The install script supports two paths:

- **Default (recommended for simple installs):** the IIS-virtual `IIS AppPool\<IisSiteName>` identity. No password, no Active Directory, no domain rights. The script grants it read on `appsettings.Production.json` via NTFS ACLs. This is what the script picks when `-AppPoolIdentity` is empty.
- **Domain service account:** if your environment requires a named domain account (e.g. for centralized auditing), pass `-AppPoolIdentity DOMAIN\svcAraApp` and the script will prompt for the password securely.

If you go with a domain service account, also do the following:

```powershell
# Add the account to IIS_IUSRS so IIS can hand it the worker process
Add-LocalGroupMember -Group IIS_IUSRS -Member "DOMAIN\svcAraApp"

# Grant 'Log on as a service' (this requires the SecEdit utility or Group Policy;
# in domain environments it is usually delegated by AD policy, not this script).
```

**Verify:**

```powershell
# For the virtual identity:
Get-WebAppPoolState -Name ARA   # after the install script runs

# For a domain account:
Get-LocalGroupMember -Group IIS_IUSRS | Where-Object Name -like "*svcAraApp"
```

WS 2019 vs WS 2022: identical.

### 4. SQL connectivity (Azure SQL Managed Instance)

ARA targets Azure SQL Managed Instance with **SQL Authentication** (D3). The application server's outbound rules must allow TCP 1433 to the MI endpoint.

**Verify connectivity from the box:**

```powershell
Test-NetConnection -ComputerName <sqlmi-host>.database.windows.net -Port 1433
# Expect TcpTestSucceeded : True. If False, the firewall rule is missing.
```

**Verify the SQL login can reach `ara_new`:** use SSMS or `sqlcmd`. Outside the scope of this script — handed to the DBA.

WS 2019 vs WS 2022: identical (Azure SQL MI is reached the same way).

### 5. Outbound HTTPS allowlist

The on-prem server (per D10) does not have unrestricted internet access. The runbook's networking chapter (`docs/ship/TLS_AND_NETWORKING.md`, Item 8d, lands on a follow-up branch) lists the exact host:port pairs the firewall must permit. Until that doc lands, the short list is:

- Okta test (`hii-test.oktapreview.com:443`)
- Okta production (`hii.okta-gov.com:443`)
- Azure SQL Managed Instance endpoint (`tcp/1433` + the MI redirect range)
- Application Insights ingestion (`*.in.applicationinsights.azure.com:443` + `*.livediagnostics.monitor.azure.com:443`)
- M365 SMTP relay if you're enabling SMTP (`smtp.office365.com:587` for commercial M365, or `smtp.office365.us:587` for GCC High)

**Verify each before running the install script** (this is the Item 8e check):

```powershell
Test-NetConnection -ComputerName hii-test.oktapreview.com         -Port 443
Test-NetConnection -ComputerName <appinsights-region>.in.applicationinsights.azure.com -Port 443
Test-NetConnection -ComputerName smtp.office365.com               -Port 587   # if SMTP is enabled
```

Expect `TcpTestSucceeded : True` for each. Any `False` = the network rule is missing — file a firewall ticket before continuing.

WS 2019 vs WS 2022: identical.

### 6. Internal-CA certificate

`Install-AraOnPremises.ps1` does not request the cert — it binds an existing one. Obtain the cert for the environment's hostname (`ara.hii-tsd.com` for prod, `aradev.hii-tsd.com` for dev / test) from the internal CA out-of-band, then import it into `LocalMachine\My`:

```powershell
# After receiving the .pfx (with private key) from the CA team:
Import-PfxCertificate -FilePath C:\Staging\ara-hii-tsd-com.pfx `
    -CertStoreLocation Cert:\LocalMachine\My `
    -Password (Read-Host "PFX password" -AsSecureString)
```

**Verify:**

```powershell
Get-ChildItem Cert:\LocalMachine\My |
    Where-Object Subject -match "CN=ara\.hii-tsd\.com" |
    Format-List Subject, NotAfter, Thumbprint
# Expect one row with NotAfter in the future and a Thumbprint to pass to -CertSubject.
```

WS 2019 vs WS 2022: identical.

### 7. Certificate renewal

The internal-CA cert lifetime is set by your CA policy. When it nears expiry:

1. Request the renewed cert.
2. Import it into `LocalMachine\My` (step 6).
3. Re-run `Install-AraOnPremises.ps1` with the same parameters; `Resolve-CertThumbprint` will pick the certificate with the latest `NotAfter`, and `Set-IisSite` will rebind 443 to the new thumbprint.

No application restart is required for cert rotation alone, but re-running the install script is the safe path because it explicitly re-binds the SSL.
