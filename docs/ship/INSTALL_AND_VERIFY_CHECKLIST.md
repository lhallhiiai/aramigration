# ARA on-prem — install & verification checklist

A single, top-to-bottom, checkbox-driven walkthrough for installing ARA on a fresh Windows Server box (2019 or 2022) and verifying the result. Print this, work through it sequentially, tick each `[ ]` as you confirm the step landed.

**This doc is self-contained.** With the values from §1 in hand, an operator can complete the full install without opening another doc. Cross-references to `docs/ship/ON_PREM_DEPLOYMENT.md` and `docs/ship/TLS_AND_NETWORKING.md` are provided for deeper background, not as required reading.

**Conventions:**

- `[ ]` next to every actionable step
- *Where:* line above each step names the machine (dev workstation / target server / SQL host / browser / Azure portal)
- Code blocks tagged with the shell type (`powershell`, `bash`, `sql`, `xml`, `text`)
- Sentinel placeholders look like `<YOUR_THUMBPRINT_HERE>` — replace with values from §1 before running. Inside PowerShell blocks they appear as `"<YOUR_THUMBPRINT_HERE>"` (quoted) so the unmodified command parses cleanly; substitute the placeholder text **including or excluding** the surrounding quotes — both `"abc123"` and `abc123` work for typed parameters via PS auto-conversion
- Both **Windows Server 2019** and **Windows Server 2022** are supported; differences are called out inline

**Sections:**

1. [Pre-install information gathering](#1-pre-install-information-gathering)
2. [Target server prerequisites](#2-target-server-prerequisites)
3. [TLS certificate setup](#3-tls-certificate-setup)
4. [Build & stage the publish bundle](#4-build--stage-the-publish-bundle)
5. [Run the installer](#5-run-the-installer)
6. [Database migrations](#6-database-migrations)
7. [Smoke tests](#7-smoke-tests)
8. [Post-install sign-off](#8-post-install-sign-off)
9. [Rollback (reference)](#9-rollback-reference)

---

## 1. Pre-install information gathering

Collect every value below **before** you start. The right column tells you which later section consumes the value. Anything missing here will block you mid-install.

| # | Value | Where to get it | Used in |
|---|-------|-----------------|---------|
| 1.1 | Target server FQDN (e.g. `agxmthrisweb01.hii-tsd.com`) | Server build sheet / IT inventory | §2, §5, §7 |
| 1.2 | Cert hostname (`ara.hii-tsd.com` for prod, `aradev.hii-tsd.com` for dev/test) | Decided by which environment this server is for | §3, §5 |
| 1.3 | Internal-CA cert `.pfx` file + its PFX password | Internal CA team / cert request workflow | §3 |
| 1.4 | TLS cert thumbprint (40 hex chars) | Captured **after** §3.4 cert import | §5 |
| 1.5 | IIS site name | Operator choice; default `ARA` | §5, §7 |
| 1.6 | Install path on target | Operator choice; default `C:\inetpub\sites\ARA` | §5 |
| 1.7 | App pool identity decision | Default = IIS-virtual `IIS AppPool\<SiteName>` (no password). Domain account = pass `-AppPoolIdentity DOMAIN\svcAraApp` and have its password ready | §5 |
| 1.8 | Azure SQL Managed Instance hostname (e.g. `<sqlmi-name>.database.windows.net`) | DBA / Azure portal → SQL MI overview blade | §2, §5, §6, §7 |
| 1.9 | Database name | DBA — typically `ara_new` | §5, §6, §7 |
| 1.10 | SQL Auth username + password (login on `ara_new` with `db_datareader` + `db_datawriter` + `EXECUTE`) | DBA | §2, §5, §6 |
| 1.11 | Okta authorization-server Issuer URL (e.g. `https://hii.okta-gov.com/oauth2/default`) | Okta admin console → API → Authorization Servers | §5, §7 |
| 1.12 | Okta Audience (typically `api://default`) | Same source | §5, §7 |
| 1.13 | Okta SPA Client ID | Okta admin console → Applications → SPA app integration | §4 (frontend build) |
| 1.14 | App Insights connection string (`InstrumentationKey=...;IngestionEndpoint=...`) | Azure portal → Application Insights resource → Overview blade | §2, §5, §7 |
| 1.15 | App Insights ingestion hostname (e.g. `westus2-2.in.applicationinsights.azure.com`) | Pull the host out of the IngestionEndpoint URL in 1.14 | §2 |
| 1.16 | SMTP relay host | M365 / Exchange admin (or pass empty to fall back to `LoggingEmailService`) | §2, §5, §7 |
| 1.17 | SMTP relay port | M365 admin — commonly 25 (no TLS) or 587 (STARTTLS) | §5 |
| 1.18 | SMTP `SecureSocketOptions` | Pick one: `None`, `Auto`, `SslOnConnect`, `StartTls`, `StartTlsWhenAvailable`. Default `Auto` lets MailKit negotiate from the port | §5 |
| 1.19 | From-address for outbound mail (typically `ara@hii-tsd.com`) | Per CLAUDE.md / org policy; mailbox must exist on the relay's allowlist | §5, §7 |
| 1.20 | AllowedOrigin for CORS (full HTTPS URL of the frontend, typically same as `https://<cert-hostname>`) | Same as the IIS site hostname unless the SPA is hosted separately | §5 |

**Information-gathering checklist:**

- [ ] All 20 values from the table above are captured in a working notes file (kept secure — items 1.10, 1.14, and 1.16 are sensitive)
- [ ] Sensitive values (SQL password, App Insights connection string, SMTP-related items) are stored somewhere that will survive the install session (password manager, sealed envelope, etc.) — they will be re-entered each time the installer runs

---

## 2. Target server prerequisites

*Where: target server, elevated PowerShell, throughout this section.*

### 2.1 OS version check

- [ ] **Confirm OS is Windows Server 2019 or 2022**

  ```powershell
  (Get-CimInstance Win32_OperatingSystem).Caption
  ```

  Expect output containing `Windows Server 2019` **or** `Windows Server 2022`. Anything else = stop, this checklist does not cover other OS versions.

### 2.2 PowerShell version

- [ ] **Confirm PS 5.1 or higher**

  ```powershell
  $PSVersionTable.PSVersion
  ```

  Expect `Major` >= 5. Both WS 2019 and WS 2022 ship PS 5.1 in-box.

### 2.3 Disk space

- [ ] **Confirm at least 5 GB free on the system drive**

  ```powershell
  Get-PSDrive C | Select-Object Used, Free
  ```

  Expect `Free` >= 5,000,000,000 (5 GB). Adjust the threshold if the install path is on a non-C drive.

### 2.4 Install IIS roles + features

- [ ] **Install all required IIS roles**

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

  Expect `Success : True` in the output.

- [ ] **Verify all roles installed**

  ```powershell
  Get-WindowsFeature -Name Web-Server, Web-Mgmt-Console |
      Where-Object InstallState -ne "Installed"
  ```

  Expect **zero rows**. Any row returned = a missing role; re-run the install command.

- [ ] **Confirm `WebAdministration` module loads**

  ```powershell
  Import-Module WebAdministration
  Get-Item IIS:\Sites\Default*
  ```

  Expect the IIS provider to load with no errors.

### 2.5 Install the .NET 10 ASP.NET Core Hosting Bundle

- [ ] **Download** the latest **ASP.NET Core 10 Hosting Bundle** for Windows from <https://dotnet.microsoft.com/download/dotnet/10.0>

- [ ] **Install** by running the downloaded `.exe`. For silent install:

  ```powershell
  # Adjust the filename to match what you downloaded:
  Start-Process -FilePath "C:\Staging\dotnet-hosting-10.0.x-win.exe" `
      -ArgumentList "/install","/quiet","/norestart" -Wait
  ```

- [ ] **Verify the runtime is registered**

  ```powershell
  & "$env:ProgramFiles\dotnet\dotnet.exe" --list-runtimes |
      Select-String "Microsoft.AspNetCore.App 10\."
  ```

  Expect at least one line, e.g. `Microsoft.AspNetCore.App 10.0.x [...]`.

- [ ] **Verify the IIS native module is in place**

  ```powershell
  Test-Path "$env:SystemRoot\System32\inetsrv\aspnetcorev2.dll"
  ```

  Expect `True`.

### 2.6 SQL connectivity smoke (Item 8e — hard gate)

- [ ] **TCP path to SQL MI is open on 1433**

  ```powershell
  Test-NetConnection -ComputerName "<SQL_MI_HOSTNAME_FROM_1.8>" -Port 1433
  ```

  Expect `TcpTestSucceeded : True`. **If False — STOP.** File a network ticket; do not continue. Without this rule the app boots but every query fails.

- [ ] **SQL MI redirect range is open on 11000-11999** (load-bearing — see `TLS_AND_NETWORKING.md` §3 for why)

  ```powershell
  # Spot-check at the bottom and top of the range:
  Test-NetConnection -ComputerName "<SQL_MI_HOSTNAME_FROM_1.8>" -Port 11000
  Test-NetConnection -ComputerName "<SQL_MI_HOSTNAME_FROM_1.8>" -Port 11999
  ```

  Expect both to succeed (the gateway answers on at least some ports in this range from any reachable client). If both fail, every SQL query will hang silently — file the firewall rule.

- [ ] **SQL login can read `ara_new`** (run from any machine with `sqlcmd` and credential reach — target server, dev workstation, or DBA machine)

  ```powershell
  sqlcmd -S "<SQL_MI_HOSTNAME_FROM_1.8>" -U "<SQL_USER_FROM_1.10>" -P "<SQL_PASSWORD_FROM_1.10>" `
      -d "<DB_NAME_FROM_1.9>" -Q "SELECT TOP 1 name FROM sys.tables ORDER BY name"
  ```

  Expect at least one row OR an empty result. Any error = login or permission problem; coordinate with the DBA before continuing.

### 2.7 Outbound HTTPS allowlist (Item 8e — hard gate)

*Where: target server, elevated PowerShell.*

- [ ] **Okta tenant is reachable**

  ```powershell
  # Use the host that matches your environment (dev/test cert -> hii-test, prod cert -> hii.okta-gov):
  Test-NetConnection -ComputerName hii-test.oktapreview.com -Port 443
  Test-NetConnection -ComputerName hii.okta-gov.com         -Port 443
  ```

  Expect `TcpTestSucceeded : True` for at least the tenant matching this server's cert. **If False — STOP.** Auth will not work.

- [ ] **Application Insights ingestion is reachable**

  ```powershell
  Test-NetConnection -ComputerName "<APP_INSIGHTS_INGESTION_HOST_FROM_1.15>" -Port 443
  ```

  Expect `TcpTestSucceeded : True`. If False, telemetry will be silently dropped — the app still works but you'll be blind in production.

- [ ] **M365 SMTP relay is reachable** *(skip if SMTP is intentionally unset — the app falls back to `LoggingEmailService`)*

  ```powershell
  Test-NetConnection -ComputerName "<SMTP_RELAY_HOST_FROM_1.16>" -Port "<SMTP_PORT_FROM_1.17>"
  ```

  Expect `TcpTestSucceeded : True`.

### 2.8 Prereq services

- [ ] **W3SVC (IIS) service is running**

  ```powershell
  Get-Service W3SVC | Select-Object Status, StartType
  ```

  Expect `Status : Running` and `StartType : Automatic`.

- [ ] **WAS (Windows Process Activation Service) is running**

  ```powershell
  Get-Service WAS | Select-Object Status, StartType
  ```

  Expect `Status : Running` and `StartType : Automatic` (or `Manual` — IIS starts it on demand).

---

## 3. TLS certificate setup

Background: `docs/ship/TLS_AND_NETWORKING.md` §2 and `docs/ship/ON_PREM_DEPLOYMENT.md` §1.4.

*Where: target server, elevated PowerShell, throughout this section.*

### 3.1 Stage the cert file

- [ ] **Copy the `.pfx` file from §1.3 to a path on the server** (e.g. `C:\Staging\ara-cert.pfx`)

  Method is whatever your environment supports (SMB copy, RDP clipboard transfer, etc.). After staging, the file should be at a known path.

### 3.2 Import the cert into `LocalMachine\My`

- [ ] **Import**

  ```powershell
  Import-PfxCertificate -FilePath "C:\Staging\ara-cert.pfx" `
      -CertStoreLocation Cert:\LocalMachine\My `
      -Password (Read-Host "PFX password" -AsSecureString)
  ```

  When prompted, paste the PFX password from §1.3. Expect the cmdlet to print the `Thumbprint` and `Subject` of the imported cert.

### 3.3 Capture the thumbprint (record this — it's value 1.4)

- [ ] **List the cert and write down the thumbprint**

  ```powershell
  Get-ChildItem Cert:\LocalMachine\My |
      Where-Object Subject -match "CN=<CERT_HOSTNAME_FROM_1.2>" |
      Format-List Subject, NotAfter, Thumbprint, HasPrivateKey
  ```

  Expect **one row** with:
  - `Subject` matching the hostname from §1.2
  - `NotAfter` in the future
  - `HasPrivateKey : True`
  - `Thumbprint` — 40 hex chars; **write this down as value 1.4**

  If `HasPrivateKey : False` → re-import using the `.pfx` (private key included), not a `.cer` (public key only).

### 3.4 Sanity-check what you wrote down

- [ ] **Confirm the captured thumbprint resolves and is private-key-bearing**

  ```powershell
  $t = "<YOUR_THUMBPRINT_HERE>"  # paste value 1.4
  Get-Item "Cert:\LocalMachine\My\$t" |
      Select-Object Subject, NotAfter, HasPrivateKey
  ```

  Expect a single result with `HasPrivateKey : True` and `NotAfter` in the future. The installer's `Resolve-Cert` step does this same check; verifying by hand here means a typo in the thumbprint surfaces now, not mid-install.

---

## 4. Build & stage the publish bundle

*Where: dev workstation OR a CI runner — **not** the target server. The target server only has the .NET 10 runtime; building requires the SDK.*

### 4.1 Clean checkout — security gate

This step is non-negotiable. Building from a developer's daily-driver checkout risks shipping local-only files (in-flight uncommitted changes, scratch files, IDE artifacts). The csproj structurally excludes `appsettings.Development.json` from publish output (see step 4.3), but other working files are not centrally protected.

- [ ] **Make a fresh clone in a clean location**

  ```bash
  cd /tmp   # or any clean directory
  git clone https://github.com/lhallhiiai/aramigration.git ara-publish-build
  cd ara-publish-build
  git checkout <RELEASE_TAG_OR_COMMIT_SHA>
  git status   # expect: nothing to commit, working tree clean
  ```

- [ ] **Confirm `appsettings.Development.json` does NOT exist in the source tree**

  ```bash
  ls new/backend/src/ARA.Api/appsettings.Development.json
  ```

  Expect `No such file or directory`. If the file is present, **STOP** and re-clone — your "clean" checkout is contaminated.

### 4.2 Build the backend publish bundle

*Where: dev workstation, working directory is the clean clone root.*

- [ ] **Publish**

  ```bash
  dotnet publish new/backend/src/ARA.Api/ARA.Api.csproj -c Release -o ./publish-output
  ```

  Expect `Build succeeded.` with `0 Error(s)`. Any `warning : appsettings.Development.json was found in the publish output ...` indicates the structural exclusion was bypassed — **STOP** and investigate.

### 4.3 Verify publish output

- [ ] **`appsettings.Production.json.example` IS in the output**

  ```bash
  ls publish-output/appsettings.Production.json.example
  ```

  Expect the file path to print. The installer reads this template in §5.

- [ ] **`appsettings.Development.json` is NOT in the output** *(security gate)*

  ```bash
  ls publish-output/appsettings.Development.json 2>&1 | head -1
  ```

  Expect `No such file or directory`. **If the file IS in the output, STOP.** Do not ship the bundle. Investigate the csproj `Content Update="appsettings.Development.json" CopyToPublishDirectory="Never"` entry — it has been removed or overridden.

- [ ] **`appsettings.json` (the base config) IS in the output**

  ```bash
  ls publish-output/appsettings.json
  ```

  Expect the file path to print.

### 4.4 Build the frontend SPA bundle

*Where: dev workstation, working directory `new/frontend/` inside the clean clone.*

- [ ] **Set the production env vars and build**

  ```bash
  export VITE_OKTA_ISSUER="<OKTA_ISSUER_FROM_1.11>"
  export VITE_OKTA_CLIENT_ID="<OKTA_SPA_CLIENT_ID_FROM_1.13>"
  export VITE_API_BASE="https://<CERT_HOSTNAME_FROM_1.2>/api"
  npm ci
  npm run build
  ```

  Expect `built in <N>s` at the end, with `dist/` populated.

- [ ] **Stage the frontend `dist/` into the publish bundle**

  ```bash
  mkdir -p ../publish-output/wwwroot
  cp -r dist/* ../publish-output/wwwroot/
  ```

  (Adjust paths if your IIS site root expects the SPA in a different sub-directory.)

### 4.5 Zip the bundle and transfer to the target server

*Where: dev workstation, working directory the clean clone root.*

- [ ] **Zip the bundle**

  ```bash
  cd publish-output
  zip -r ../ARA-Publish.zip .
  cd ..
  ls -la ARA-Publish.zip
  ```

  Expect a single zip file with non-zero size.

- [ ] **Transfer `ARA-Publish.zip` to the target server** (e.g. `C:\Staging\ARA-Publish.zip`)

  Method is whatever your environment supports (SMB copy, RDP clipboard, robocopy across the internal network, `pscp`, etc.). After transfer, verify the file lands on the target server intact:

  *Where: target server, PowerShell.*

  ```powershell
  Get-Item C:\Staging\ARA-Publish.zip | Select-Object Length, LastWriteTime
  ```

  Expect a non-zero `Length` and a fresh `LastWriteTime`.

---

## 5. Run the installer

*Where: target server, elevated PowerShell, working directory at the repo checkout (or wherever you copied `Install-AraOnPremises.ps1` to).*

### 5.1 Stage the install script

- [ ] **Have `scripts/Install-AraOnPremises.ps1` on the target server.** Either clone the repo to the server, or copy just the script file. Working directory for §5 commands assumes the script is at `C:\Staging\Install-AraOnPremises.ps1` — adjust paths as needed.

### 5.2 Dry run with `-WhatIf`

- [ ] **Run with `-WhatIf` first**

  ```powershell
  C:\Staging\Install-AraOnPremises.ps1 `
      -PublishBundlePath  C:\Staging\ARA-Publish.zip `
      -SiteHostname       "<CERT_HOSTNAME_FROM_1.2>" `
      -CertThumbprint     "<YOUR_THUMBPRINT_FROM_1.4>" `
      -SqlConnectionString "Server=tcp:<SQL_MI_HOSTNAME_FROM_1.8>,1433;Database=<DB_NAME_FROM_1.9>;User ID=<SQL_USER_FROM_1.10>;Password=<SQL_PASSWORD_FROM_1.10>;Encrypt=True;" `
      -OktaIssuer         "<OKTA_ISSUER_FROM_1.11>" `
      -OktaAudience       "<OKTA_AUDIENCE_FROM_1.12>" `
      -AppInsightsConnectionString "<APP_INSIGHTS_CONN_STRING_FROM_1.14>" `
      -AllowedOrigin      "https://<CERT_HOSTNAME_FROM_1.2>" `
      -SmtpHost           "<SMTP_RELAY_HOST_FROM_1.16>" `
      -SmtpPort           "<SMTP_PORT_FROM_1.17>" `
      -SmtpSecureSocketOptions "<SMTP_SSO_FROM_1.18>" `
      -SmtpFromAddress    "<FROM_ADDRESS_FROM_1.19>" `
      -WhatIf
  ```

  Expect the script to:
  - Print `Detected OS: Windows Server 20XX`
  - Print the resolved cert: `Thumbprint`, `Subject`, `NotAfter`
  - Print the parameter summary block (`IisSiteName`, `InstallPath`, `SiteHostname`, etc.)
  - List every action it would take prefixed with `What if:` (no actual changes)

  Anything unexpected = stop and ask before re-running without `-WhatIf`.

  *If skipping SMTP* (will use `LoggingEmailService` fallback), omit the four `-Smtp*` parameters entirely.

  *If using a domain app pool identity*, add `-AppPoolIdentity DOMAIN\svcAraApp`; the script will prompt for the password securely after `-WhatIf` review (real run only).

### 5.3 Real run

- [ ] **Re-run with `-WhatIf` removed**

  Same command as §5.2, drop the `-WhatIf`. Expect to see, in order:
  - OS and prereq checks pass
  - Cert validation prints the resolved thumbprint
  - `Installing ARA on Windows Server 20XX` header
  - Bundle staging output (robocopy summary)
  - `Wrote C:\inetpub\sites\ARA\appsettings.Production.json` (in verbose mode)
  - `ACLs locked down on ...` (in verbose mode)
  - IIS site / app pool create or update
  - Final block:

    ```text
    Install complete.
      Site:           IIS:\Sites\<SITE_NAME>
      PhysicalPath:   <INSTALL_PATH>
      AppPool:        <SITE_NAME> (identity: ...)
      HTTPS binding:  https://<HOST>:443 (cert thumbprint <THUMBPRINT>)
    ```

- [ ] **Confirm the script reached `Install complete.`** with no red error output above it. If the script threw before that line, capture the error and **do not proceed**; the install is incomplete.

### 5.4 Verify install path contents

- [ ] **`appsettings.Production.json` was generated**

  ```powershell
  Test-Path "<INSTALL_PATH_FROM_1.6>\appsettings.Production.json"
  ```

  Expect `True`.

- [ ] **No placeholders remain in `appsettings.Production.json`** *(operator runs as admin since ACLs are locked)*

  ```powershell
  Select-String -Path "<INSTALL_PATH_FROM_1.6>\appsettings.Production.json" `
      -Pattern '<.*>'
  ```

  Expect **zero matches**. Any line returned = a value the installer didn't substitute. Investigate before continuing.

- [ ] **App binary is in place**

  ```powershell
  Test-Path "<INSTALL_PATH_FROM_1.6>\ARA.Api.dll"
  ```

  Expect `True`.

- [ ] **Frontend SPA is in place** *(skip if you didn't stage the SPA into the bundle in §4.4)*

  ```powershell
  Test-Path "<INSTALL_PATH_FROM_1.6>\wwwroot\index.html"
  ```

  Expect `True`.

### 5.5 Verify NTFS ACLs on the config file

- [ ] **`appsettings.Production.json` is locked down**

  ```powershell
  icacls "<INSTALL_PATH_FROM_1.6>\appsettings.Production.json"
  ```

  Expect ONLY these access entries (no `Everyone`, no `BUILTIN\Users`, no `Authenticated Users`):
  - `BUILTIN\Administrators:(F)`
  - `NT AUTHORITY\SYSTEM:(F)`
  - The app pool identity with `(R)` — typically `IIS APPPOOL\<SITE_NAME>` for the default virtual identity, or `DOMAIN\svcAraApp` if you supplied a domain account

  If any extra access entry is present, the file is over-shared — **STOP** and investigate.

### 5.6 Verify IIS site + binding

- [ ] **Site exists and points at the install path**

  ```powershell
  Get-Item "IIS:\Sites\<SITE_NAME_FROM_1.5>" |
      Select-Object name, physicalPath, applicationPool, state
  ```

  Expect:
  - `name` = your site name from §1.5
  - `physicalPath` = `<INSTALL_PATH_FROM_1.6>`
  - `applicationPool` = the same site name (or whatever you customized)
  - `state` = `Started`

- [ ] **HTTPS binding is on 443 with the correct cert thumbprint**

  ```powershell
  Get-WebBinding -Name "<SITE_NAME_FROM_1.5>" -Protocol https |
      Select-Object protocol, bindingInformation, certificateHash
  ```

  Expect:
  - `protocol` = `https`
  - `bindingInformation` = `*:443:<CERT_HOSTNAME_FROM_1.2>`
  - `certificateHash` = `<YOUR_THUMBPRINT_FROM_1.4>` (uppercase)

  If `certificateHash` is empty or different = the cert binding step in the installer didn't land; do not proceed until resolved.

---

## 6. Database migrations

*Where: any machine with `sqlcmd` and credential / network reach to the SQL MI — typically the target server (already has SQL connectivity verified in §2.6) or the dev workstation.*

### 6.1 Schema migrations

The repo's `scripts/sql/` folder holds 7 numbered migration scripts (`001_tables.sql` through `007_user_provisioning.sql`). Apply them in order against the target database.

- [ ] **List the migrations**

  ```bash
  ls scripts/sql/*.sql
  ```

  Expect 7 files: `001_tables.sql`, `002_seed_data.sql`, `003_stored_procedures.sql`, `004_rename_entra_column.sql`, `005_approval_delegation_rejection.sql`, `006_archived_includes_approved.sql`, `007_user_provisioning.sql`. If there are more (e.g. `008_*` and beyond), apply those too.

- [ ] **Apply each migration in order**

  *Where: machine with `sqlcmd` and SQL reach. Working directory: the repo root.*

  ```powershell
  $sqlServer = "<SQL_MI_HOSTNAME_FROM_1.8>"
  $sqlUser   = "<SQL_USER_FROM_1.10>"
  $sqlPass   = "<SQL_PASSWORD_FROM_1.10>"
  $sqlDb     = "<DB_NAME_FROM_1.9>"

  foreach ($file in (Get-ChildItem scripts\sql\*.sql | Sort-Object Name)) {
      Write-Host "Applying $($file.Name) ..." -ForegroundColor Cyan
      & sqlcmd -S $sqlServer -U $sqlUser -P $sqlPass -d $sqlDb -i $file.FullName
      if ($LASTEXITCODE -ne 0) {
          Write-Error "FAILED on $($file.Name) with exit code $LASTEXITCODE"
          break
      }
  }
  ```

  Expect each `Applying ...` line to be followed by clean output (or expected schema-change messages). Any `FAILED on <name>` halts the loop — **STOP** and resolve before continuing.

  *Note:* migrations are not idempotent in general. Re-running an already-applied migration may error (e.g. `CREATE TABLE` on an existing table). On a fresh database this is the right path; on a database that has already been partially populated, coordinate with the DBA.

### 6.2 Verify schema

- [ ] **Stored procedures the app calls are present**

  ```powershell
  sqlcmd -S "<SQL_MI_HOSTNAME_FROM_1.8>" -U "<SQL_USER_FROM_1.10>" `
      -P "<SQL_PASSWORD_FROM_1.10>" -d "<DB_NAME_FROM_1.9>" `
      -Q "SELECT name FROM sys.procedures WHERE name LIKE 'usp_%' ORDER BY name"
  ```

  Expect a long list including (spot-check these): `usp_UserProvision` (from `007`), `usp_EmailLogCreate` (from `005`), `usp_AraExpireOverdue` (from `005`).

- [ ] **Approval matrix seed data is loaded** (the 10-row matrix per CLAUDE.md)

  ```powershell
  sqlcmd -S "<SQL_MI_HOSTNAME_FROM_1.8>" -U "<SQL_USER_FROM_1.10>" `
      -P "<SQL_PASSWORD_FROM_1.10>" -d "<DB_NAME_FROM_1.9>" `
      -Q "SELECT COUNT(*) AS RowCount_Threshold FROM Threshold"
  ```

  Expect `RowCount_Threshold` = 10 (or whatever the current matrix size is per CLAUDE.md).

### 6.3 Historical-data migration *(skip on a re-deploy of an already-populated environment)*

If this is a brand-new prod environment AND the legacy `ara_legacy` data has not yet been brought forward, run `scripts/Invoke-AraDataMigration.ps1` against the latest production-restored copy of `ara_legacy`. The script is **destructive-idempotent** — it clears all target tables in reverse FK order before reloading. Do not run it after users have started entering data into the new system.

- [ ] **(Conditional)** Run the historical-data migration per `docs/ship/HISTORICAL_MIGRATION.md`

  ```powershell
  .\scripts\Invoke-AraDataMigration.ps1 `
      -SourceServer "<LEGACY_SOURCE_HOST>" -SourceDatabase "ara_legacy" `
      -TargetServer "<SQL_MI_HOSTNAME_FROM_1.8>" -TargetDatabase "<DB_NAME_FROM_1.9>" `
      -SourceUser "<LEGACY_USER>" -SourcePassword "<LEGACY_PASSWORD>" `
      -TargetUser "<SQL_USER_FROM_1.10>" -TargetPassword "<SQL_PASSWORD_FROM_1.10>"
  ```

  Expect per-table row counts at the end matching `ara_legacy`. If they don't match, **STOP** and capture the diff before continuing.

---

## 7. Smoke tests

### 7.1 Health probes

*Where: target server (or any machine on the internal network with reach to the site), elevated PowerShell.*

- [ ] **`/health/live` returns 200**

  ```powershell
  Invoke-WebRequest "https://<CERT_HOSTNAME_FROM_1.2>/health/live" -SkipCertificateCheck |
      Select-Object StatusCode, Content
  ```

  Expect `StatusCode : 200` and an empty `Content`.

- [ ] **`/health/ready` returns 200 with both checks `Healthy`**

  ```powershell
  $r = Invoke-WebRequest "https://<CERT_HOSTNAME_FROM_1.2>/health/ready" -SkipCertificateCheck
  $r.StatusCode
  $r.Content
  ```

  Expect `StatusCode : 200` and `Content` parseable as JSON with shape:

  ```text
  {
    "status": "Healthy",
    "totalDurationMs": ...,
    "results": {
      "sql":  { "status": "Healthy", ... },
      "okta": { "status": "Healthy", ... }
    }
  }
  ```

  - `status: "Healthy"` overall: pass.
  - `status: "Degraded"` overall: investigate which sub-check is degraded before signing off — `okta` Degraded usually means `Okta:Issuer` is empty (mis-config); `sql` Degraded usually means the connection string or login is wrong.
  - `status: "Unhealthy"` or HTTP 503: **STOP**, capture which sub-check is unhealthy and the `error` field, debug.

### 7.2 Application Insights ingestion

*Where: Azure portal, signed in as someone with read access to the App Insights resource from §1.14.*

- [ ] **Generate at least one request** by hitting `/health/live` or `/health/ready` (§7.1 already does this)

- [ ] **Check the Azure portal**

  Navigate: **Azure portal → search for the App Insights resource name → Logs (Analytics)**. Run:

  ```text
  requests
  | where timestamp > ago(15m)
  | order by timestamp desc
  | take 20
  ```

  Expect at least one row from your smoke requests within 60 seconds of running them. Other useful blades:
  - **Application Insights → Live Metrics** (real-time stream — confirms outbound is working *right now*)
  - **Application Insights → Failures** (any 4xx/5xx the smoke produced)

  If nothing arrives within 5 minutes:
  - Re-check the connection string in the install (`Get-Content "<INSTALL_PATH>\appsettings.Production.json"` and look at `ApplicationInsights.ConnectionString`)
  - Re-check the outbound network rule from §2.7 (`Test-NetConnection` to the ingestion host)

### 7.3 Okta auth flow end-to-end

*Where: a browser on a workstation with reach to the site.*

- [ ] **Hit the app**

  Navigate to `https://<CERT_HOSTNAME_FROM_1.2>/`. Expect the SPA to load and (if not already authenticated) redirect to Okta.

- [ ] **Sign in** as a test user that exists in the Okta tenant matching this server's environment.

  Expect Okta to redirect back to the app after successful auth, with a session established (you should see the landing page / My Action List).

- [ ] **Verify JIT user provisioning** *(first sign-in only)*

  *Where: machine with `sqlcmd` reach.*

  ```powershell
  sqlcmd -S "<SQL_MI_HOSTNAME_FROM_1.8>" -U "<SQL_USER_FROM_1.10>" `
      -P "<SQL_PASSWORD_FROM_1.10>" -d "<DB_NAME_FROM_1.9>" `
      -Q "SELECT TOP 5 UserId, ExternalUserId, Email, DisplayName, CreatedAt FROM [User] ORDER BY UserId DESC"
  ```

  Expect a row with `ExternalUserId` matching your Okta `sub` (a long opaque string), `Email` matching your test user's email, and `CreatedAt` near the time you signed in.

  If no row appears AND the app returned an error on first sign-in, check the app logs (or Application Insights from §7.2 → Failures blade).

### 7.4 Real SMTP send (skip if SMTP is intentionally unset)

*Where: signed in to the app as a user with the Creator / Program Manager role.*

- [ ] **Trigger a workflow email**

  Create a new ARA, fill the PM section, and click **Sign & Submit**. This fires the first workflow email (PM → CA notification) to whoever the CA is for the matrix entry.

- [ ] **Verify the email arrived**

  Check the CA recipient's mailbox. Expect an email from `<FROM_ADDRESS_FROM_1.19>` with a link to the new ARA. If the email does not arrive within ~5 minutes:
  - Check `EmailLog` (a row should still be present even if SMTP failed):

    ```powershell
    sqlcmd -S "<SQL_MI_HOSTNAME_FROM_1.8>" -U "<SQL_USER_FROM_1.10>" `
        -P "<SQL_PASSWORD_FROM_1.10>" -d "<DB_NAME_FROM_1.9>" `
        -Q "SELECT TOP 5 * FROM EmailLog ORDER BY EmailLogId DESC"
    ```

  - Row present + email did not arrive = SMTP relay path is broken (relay-side IP allowlist, network rule, or relay-side delivery issue). Pull the app logs / Application Insights for the SEND FAIL line, and coordinate with the M365 / Exchange admin.
  - No row in `EmailLog` = the workflow transition didn't fire the email at all; investigate the `AraService` workflow path (separate issue).

### 7.5 Browser smoke

*Where: a browser on a workstation with reach to the site.*

- [ ] **Cert is trusted**

  In the address bar, the lock icon should be solid (not a warning triangle / not a "Not Secure" label). If the cert shows as untrusted, the workstation does not trust the internal CA chain — either install the internal CA root cert on the workstation, or document this as the expected state for systems without the internal CA root.

- [ ] **Expected pages load**

  - Landing page (My Action List) loads with no console errors
  - Dashboard loads
  - Search ARA page loads
  - Create ARA flow opens (Creator role only)

- [ ] **Walk one ARA end-to-end** *(full smoke — confirms the entire workflow chain works on the on-prem instance)*

  - PM creates → fills → signs + submits
  - CA reviews → fills section → submits forward
  - Controller completes CLIN worksheet (Non-Early Start) or skips (Early Start) → submits for approval
  - Each approver in the matrix approves
  - Final status = `Approved`
  - `EmailLog` shows a row for every transition (and real emails arrive at each step if SMTP is enabled)

  Any failure at any step = capture the request ID from Application Insights, the `EmailLog` rows so far, and any logged exception. Don't try to fix forward — roll back per §9 and triage.

---

## 8. Post-install sign-off

The lines below mirror Item 6's on-prem readiness checklist in `docs/SHIP_PLAN.md`. Sign each one off here as you verify it during this install. Initial / date / commit-hash style — whatever your ops policy uses.

### Server foundation

- [ ] Target Windows Server identified (WS 2019 or WS 2022); OS patched; FQDN matches the cert subject
- [ ] IIS role + ASP.NET Core Hosting Bundle (.NET 10) installed; `dotnet --info` reports the runtime
- [ ] App pool service account chosen and configured per §1.7
- [ ] Azure SQL MI reachable (TCP 1433 + 11000-11999 redirect range); SQL login has `db_datareader` / `db_datawriter` / `EXECUTE` on the target database
- [ ] Outbound HTTPS allowlist verified for: Okta, Azure SQL MI, App Insights, M365 SMTP
- [ ] Internal-CA cert imported to `LocalMachine\My`, private-key-bearing, `NotAfter` in the future

### App install

- [ ] Publish bundle deployed; IIS site bound to HTTPS:443 with the internal-CA cert
- [ ] `appsettings.Production.json` generated by the installer; no `<...>` placeholders remain
- [ ] NTFS ACLs on `appsettings.Production.json` restrict to app pool identity + Administrators + SYSTEM (verified via `icacls`)
- [ ] Database migrations applied; historical-data migration run (if applicable)

### Identity + workflow path

- [ ] Okta app integration in the target tenant; redirect URIs include the bound HTTPS hostname; access granted to the right user groups
- [ ] First Okta sign-in creates a `Users` row (JIT path verified end-to-end)
- [ ] Approval matrix seed data loaded

### Health + telemetry

- [ ] `/health/live` returns 200, empty body
- [ ] `/health/ready` returns 200 with `sql=Healthy` and `okta=Healthy`
- [ ] First request after install produces a trace in App Insights within 60 seconds

### Email

- [ ] Either: SMTP configured and a test workflow email arrived AND `EmailLog` row present
- [ ] Or: SMTP intentionally unset; `EmailLog` rows still appear; operator confirmed this is intentional
- [ ] M365 service-account mailbox / shared mailbox for the `From` address exists; relay IP allowlist includes this server

### Frontend

- [ ] Frontend bundle built with the production `VITE_OKTA_*` and `VITE_API_BASE` env vars; deployed under the same IIS site
- [ ] CORS `AllowedOrigins` matches the bound HTTPS hostname; SPA can call `/api/*` cross-origin

### End-to-end

- [ ] One end-to-end test ARA walked PM → CA → Controller → all approvers → Approved on the on-prem instance, with email trail and `EmailLog` rows verified at each step

### Final

- [ ] **Production install verified and accepted.** Sign-off: ____________________ Date: ____________

---

## 9. Rollback (reference)

If §7 smoke tests fail in a way you can't fix forward (config mistake, bad release, broken SQL migration), roll back per `docs/ship/ON_PREM_DEPLOYMENT.md` §6.

**Brief summary:**

1. **Stop the app pool** to drain in-flight requests:

   ```powershell
   Stop-WebAppPool -Name "<SITE_NAME_FROM_1.5>"
   ```

2. **Restore the previous publish bundle** from your pre-install backup (you DID take one before re-deploying — see runbook §6.1):

   ```powershell
   robocopy "<BACKUP_PATH>" "<INSTALL_PATH_FROM_1.6>" /MIR /XF "appsettings.Production.json"
   ```

   (The `/XF` flag preserves the current `appsettings.Production.json` so you don't accidentally restore stale config. If a config rollback is also required, restore that file separately from its own backup, under the same restrictive ACLs.)

3. **Restart the app pool**:

   ```powershell
   Start-WebAppPool -Name "<SITE_NAME_FROM_1.5>"
   ```

4. **Re-run §7 health probes** to confirm the rolled-back release is up.

If a SQL migration was applied as part of the failed deploy and needs to be unwound, **that is a manual schema operation** — there are no automated migration-down scripts. Coordinate with the DBA before unwinding any schema change.

---

*End of checklist. Total checkboxes (excluding §1 reference table): roughly 70 across §2–§8.*
