# Local-Dev Secrets Setup

This document covers how to run the ARA app locally with **zero secrets in source**. It's the local-dev companion to Item 2 of `docs/SHIP_PLAN.md` (Secrets extraction). The Item 2 amendment of 2026-04-29 (on-prem pivot, D4) replaced the production Key Vault path with `appsettings.Production.json` secured by NTFS ACLs — see "Production wiring" below.

## Backend (`new/backend/src/ARA.Api`)

The backend reads its connection string and Okta config from .NET's standard configuration chain. In `Production`, these come from `appsettings.Production.json` on the on-prem server (see "Production wiring" below). In `Development`, use **dotnet user-secrets** — they live in `%APPDATA%\Microsoft\UserSecrets\ara-api-dev\secrets.json` (Windows) or `~/.microsoft/usersecrets/ara-api-dev/secrets.json` (macOS/Linux), outside the repo.

### One-time setup

Run from `new/backend/src/ARA.Api/`:

```powershell
dotnet user-secrets init  # already done — UserSecretsId is "ara-api-dev"
dotnet user-secrets set "ConnectionStrings:AraDatabase" "Server=<your-sql-host>;Database=ara_new;User ID=<sql-user>;Password=<sql-password>;Encrypt=True;"
dotnet user-secrets set "Okta:Issuer" "https://hii-test.oktapreview.com/oauth2/default"
```

The connection string above uses **SQL Authentication** — matches the on-prem production target (D3 of the on-prem pivot). The SQL user only needs `db_datareader`, `db_datawriter`, and `EXECUTE` against `ara_new`.

If you have an `appsettings.Development.json` from earlier work, **delete it** — the file is gitignored, but the user-secrets path is the supported mechanism going forward.

### Verifying

```powershell
dotnet user-secrets list
```

Should print the keys you set (values masked). Then:

```powershell
dotnet run
```

Should boot without errors. The Okta JWT bearer is wired to the configured issuer; if `Okta:Issuer` is empty, the dev auth fallback (`DevAuthenticationHandler`) activates instead.

## Frontend (`new/frontend`)

The frontend reads Okta config via Vite env vars (`import.meta.env.VITE_OKTA_*`). For local dev, copy the example file and fill in real values:

```powershell
cd new/frontend
copy .env.example .env.local
# Edit .env.local — set VITE_OKTA_CLIENT_ID to a real test SPA client ID.
```

`.env.local` is gitignored. Never commit it.

`okta-config.ts` throws a clear error at import time if the env vars are missing, so a misconfigured dev environment fails fast rather than running with bad config.

## Production wiring (`appsettings.Production.json` on the on-prem server)

In production, the backend reads secrets from `appsettings.Production.json` on the Windows Server box. The file is **not** tracked in source — only an `appsettings.Production.json.example` template ships in the repo (added in the install-script branch). The on-prem installer (`scripts/Install-AraOnPremises.ps1`, Item 8b) generates the real file from the template by substituting operator-supplied values, then locks it down with NTFS ACLs (read for the IIS app pool identity + local Administrators only).

Settings carried in `appsettings.Production.json`:

- `ConnectionStrings:AraDatabase` — SQL Auth connection string for Azure SQL Managed Instance
- `Okta:Issuer` and `Okta:Audience` — production Okta tenant + audience
- `ApplicationInsights:ConnectionString` — App Insights ingestion key
- `Email:Smtp:*` and `Email:FromAddress` — M365 SMTP settings (or empty to fall back to `LoggingEmailService`, see Item 8b.1)

`Program.cs` no longer wires Key Vault — the Azure Key Vault config provider was removed in the on-prem pivot (`refactor/strip-key-vault-deps`, 2026-04-29). The standard `appsettings.{Environment}.json` precedence chain is sufficient on-prem; the file's secrecy is enforced by NTFS, not encryption.

For the frontend, production injects Okta values via Vite env vars at build time (`VITE_OKTA_ISSUER`, `VITE_OKTA_CLIENT_ID`, `VITE_API_BASE`) — the build runs out-of-process from the IIS host. The on-prem deployment runbook (Item 8c) covers the build-and-publish steps for the frontend bundle.

## Verification: zero secrets in source

After the secrets-extraction work lands, this command should return no hits in tracked files:

```powershell
git grep -E "0oawy(gfqavWdJX7Nw1d7|h822mSqLuAqu1d7)|hii-test\.oktapreview\.com|Ar@AppDev"
```

If any tracked file contains an Okta clientId, an Okta tenant URL, or the dev DB password, the extraction is incomplete.
