# Local-Dev Secrets Setup

This document covers how to run the ARA app locally with **zero secrets in source**. It's the local-dev companion to Item 2 of `docs/SHIP_PLAN.md` (Secrets extraction → Key Vault).

## Backend (`new/backend/src/ARA.Api`)

The backend reads its connection string and Okta config from .NET's standard configuration chain. In `Production`, these come from Azure Key Vault (see "Production wiring" below). In `Development`, use **dotnet user-secrets** — they live in `%APPDATA%\Microsoft\UserSecrets\ara-api-dev\secrets.json` (Windows) or `~/.microsoft/usersecrets/ara-api-dev/secrets.json` (macOS/Linux), outside the repo.

### One-time setup

Run from `new/backend/src/ARA.Api/`:

```powershell
dotnet user-secrets init  # already done — UserSecretsId is "ara-api-dev"
dotnet user-secrets set "ConnectionStrings:AraDatabase" "Server=lhall-ara-dev-westus2.database.windows.net;Database=ara_new;Authentication=Active Directory Default;Encrypt=True;"
dotnet user-secrets set "Okta:Issuer" "https://hii-test.oktapreview.com/oauth2/default"
```

The connection string above uses **Active Directory Default** auth — combined with `az login`, no SQL password is needed locally. If you need SQL Auth instead, swap the `Authentication=...` segment for `User ID=...;Password=...`.

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

## Production wiring (Key Vault)

In production, the backend reads secrets from Azure Key Vault:

1. The Container App is provisioned with a managed identity that has `Key Vault Secrets User` on the prod Key Vault. *(Provisioning the Container App and Key Vault is part of Item 8 — deferred Azure resources.)*
2. The Container App config sets `KeyVaultUri=https://<kv-name>.vault.azure.net/`.
3. On boot, `Program.cs` calls `builder.Configuration.AddAzureKeyVault(new Uri(keyVaultUri), new DefaultAzureCredential())`.
4. Secrets stored in Key Vault use double-dash naming (`ConnectionStrings--AraDatabase`, `Okta--Issuer`, etc.) so .NET configuration binding maps them to nested config keys.

`DefaultAzureCredential` walks the standard chain (env → managed identity → VS credentials → `az login` → ...), so the same code works locally if anyone wants to test against a real Key Vault — just `az login` and set `KeyVaultUri`.

For the frontend, production injects Okta values via Docker build args (see `new/frontend/Dockerfile`):

```dockerfile
ARG VITE_OKTA_ISSUER
ARG VITE_OKTA_CLIENT_ID
ENV VITE_OKTA_ISSUER=$VITE_OKTA_ISSUER
ENV VITE_OKTA_CLIENT_ID=$VITE_OKTA_CLIENT_ID
```

Build args become env vars, Vite reads them at build time, and the values are baked into the bundle. Frontend builds without these args produce a binary that throws at startup — intentional fail-fast.

## Verification: zero secrets in source

After the secrets-extraction work lands, this command should return no hits in tracked files:

```powershell
git grep -E "0oawy(gfqavWdJX7Nw1d7|h822mSqLuAqu1d7)|hii-test\.oktapreview\.com|Ar@AppDev"
```

If any tracked file contains an Okta clientId, an Okta tenant URL, or the dev DB password, the extraction is incomplete.
