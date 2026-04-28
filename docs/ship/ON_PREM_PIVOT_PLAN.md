# On-Prem Pivot Plan

**Created:** 2026-04-28
**Status:** Awaiting decisions on D1–D10 below. No source changes have been made.
**Trigger:** Direction change from Azure deployment (Items 6 + 8 of `docs/SHIP_PLAN.md`) to on-premises Windows Server deployment.

This document is the planning record for the pivot. Once D1–D10 are answered, the **Sequence of execution** section below becomes the to-do list. Until then, all the existing Azure deployment artifacts under `infra/bicep/`, `scripts/Deploy-AzureInfrastructure.ps1`, and `docs/ship/AZURE_PROVISIONING.md` remain in source — drafted, not applied — for reference and revertability.

---

## Decisions — fill in the **Answer** field below each one

Each decision shapes the implementation. The work in the **Sequence of execution** section is gated on these.

### D1 — Backend host process

**Question:** IIS + ASP.NET Core Module (in-process Kestrel), Kestrel as a standalone Windows Service, or Docker Desktop on Windows running the existing Linux container?

**Why it matters:** Drives whether we keep the Dockerfile, write a `.msi`/installer, or write a Windows service install script. IIS is most "Windows-native"; service is simplest; Docker reuses what we already have but adds a Docker dependency on the server.

**Answer:** _<TBD>_

---

### D2 — Frontend host

**Question:** IIS as a static site, nginx on Windows, or skip — serve `dist/` from the same backend host?

**Why it matters:** If IIS already exists for the backend, hosting the SPA there too is the lightest option.

**Answer:** _<TBD>_

---

### D3 — SQL auth model

**Question:** Windows Integrated Security (service account → SQL login), or SQL Auth (username + password in config)?

**Why it matters:** Windows Integrated is the on-prem default and avoids storing a password. Requires a domain service account.

**Answer:** _<TBD>_

---

### D4 — Secrets store

**Question:** Plain `appsettings.Production.json` with NTFS ACLs, DPAPI-encrypted sections, environment variables on the service account, or keep using Azure Key Vault from on-prem?

**Why it matters:** Determines whether the Key Vault wiring stays, gets stripped, or gets replaced.

**Answer:** _<TBD>_

---

### D5 — Telemetry

**Question:** Keep Application Insights (works from on-prem if outbound HTTPS is allowed), switch to Serilog → local files / Windows Event Log, or wire to an on-prem APM (Elastic, Grafana, etc.)?

**Why it matters:** App Insights costs ~$0 idle and the wiring already exists; pulling it out is a real choice.

**Answer:** _<TBD>_

---

### D6 — Email provider

**Question:** For the deferred-but-eventual swap from `LoggingEmailService`: on-prem SMTP relay, M365/Exchange on-prem, or stick with logging-only?

**Why it matters:** Currently logging-only per Louis sign-off (2026-04-28); on-prem SMTP is the natural future fit.

**Answer:** _<TBD>_

---

### D7 — HTTPS termination

**Question:** Cert from the internal CA bound to IIS / Kestrel directly, or a reverse proxy (F5, NetScaler, NGINX) in front?

**Why it matters:** Drives whether the app needs to handle TLS itself.

**Answer:** _<TBD>_

---

### D8 — Deployment automation

**Question:** GitHub Actions self-hosted runner inside the network, manual MSI install, PowerShell scripts run from a jump box, or Octopus Deploy / similar?

**Why it matters:** Drives the shape of CD; PR validation CI in `.github/workflows/pr-validation.yml` is unaffected either way.

**Answer:** _<TBD>_

---

### D9 — Server target spec

**Question:** How many servers (single box vs. load-balanced pair), Windows Server version (2019/2022/2025), and is the SQL instance on the same box or separate?

**Why it matters:** Drives the install scripts and any clustering/HA story.

**Answer:** _<TBD>_

---

### D10 — Hostname

**Question:** What hostname will the app live at, and is it reachable from the internet (relevant for Okta redirect URI configuration)?

**Why it matters:** Drives CORS allowlist, Okta app integration redirect URIs, frontend `VITE_API_BASE`.

**Answer:** _<TBD>_

---

## Items to retire from `docs/SHIP_PLAN.md`

These are wholly out of scope after the pivot. The work either gets deleted or marked `[RETIRED]` for traceability.

| Item / artifact | Why retired |
| --- | --- |
| **Item 6** as currently scoped (production go-live checklist tied to Azure resources) | Rewrite — see "amended" below |
| **Item 8** (Azure Container Apps resource provisioning) | Replaced by on-prem provisioning items 8a–8e below |
| `infra/bicep/` (5 Bicep files: `main.bicep` + 4 modules) | Azure-only |
| `infra/bicep/main.parameters.dev.json` and `main.parameters.prod.json` | Azure-only |
| `scripts/Deploy-AzureInfrastructure.ps1` | Azure-only |
| `docs/ship/AZURE_PROVISIONING.md` | Azure-only |
| `KeyVaultHealthCheck` registration in `Program.cs` | Only if D4 = no Key Vault |
| `AddAzureKeyVault` config provider in `Program.cs` | Only if D4 = no Key Vault |
| `Azure.Security.KeyVault.Secrets` + `Azure.Identity` packages in `ARA.Infrastructure.csproj` and `ARA.Api.csproj` | Only if D4 = no Key Vault |

---

## Items to amend in `docs/SHIP_PLAN.md`

| Item | Amendment |
| --- | --- |
| **Item 2** (Secrets extraction) | Originally said "wire Key Vault references via Container App managed identity for production." Becomes "wire `<chosen secret store from D4>` for production." |
| **Item 5** (Application Insights + health checks) | Telemetry section becomes conditional on D5. Health checks stay; the Key Vault one drops if D4 retires KV. The `OktaMetadataHealthCheck` and `SqlConnectivityHealthCheck` are unchanged. |
| **Item 6** (Production readiness) | Rewrite the 11-line go-live checklist to be on-prem flavored. Replace lines about Container App, Key Vault references, App Insights ingestion, etc. with lines about IIS site / Windows Service health, service account permissions, on-prem SMTP/Okta connectivity, etc. |

---

## New SHIP_PLAN items to add (8a–8e replace Item 8)

| # | New item | Notes |
| --- | --- | --- |
| **8a** | On-prem Windows Server provisioning (drafted, not applied) | Server prep checklist: IIS roles + ASP.NET Core Hosting Bundle, .NET 10 runtime install, Node.js if frontend builds happen on the server, SQL Server access, service account creation, NTFS ACLs |
| **8b** | Deployment automation script (PowerShell-only per CLAUDE.md) | `scripts/Deploy-OnPremises.ps1` — copies build artifacts to the server, sets up the IIS site or Windows Service, applies SQL migrations |
| **8c** | First-deploy runbook | `docs/ship/ON_PREM_DEPLOYMENT.md` — architecture diagram, post-deploy manual steps, rollback procedure |
| **8d** | TLS cert + reverse proxy config (if applicable per D7) | `docs/ship/TLS_AND_NETWORKING.md` |
| **8e** | (Optional, only if D5 keeps App Insights) Confirm outbound HTTPS to Azure Monitor endpoints is allowed by network policy | One-line carry-forward, no code |

---

## Code change inventory — for review, not yet executed

| File | Change | Conditional on |
| --- | --- | --- |
| `new/backend/src/ARA.Api/Program.cs` | Strip `AddAzureKeyVault` block; keep `AddApplicationInsightsTelemetry` only if D5 keeps it; drop `KeyVaultHealthCheck` registration | D4, D5 |
| `new/backend/src/ARA.Api/appsettings.json` | Remove `KeyVaultUri`; remove `ApplicationInsights:ConnectionString` if D5 drops it | D4, D5 |
| `new/backend/src/ARA.Api/appsettings.Production.json` (new) | On-prem connection string with Integrated Security or SQL Auth per D3 | D3 |
| `new/backend/src/ARA.Infrastructure/Database/SqlConnectionFactory.cs` | No code change if connection string handles it; verify Integrated Security path works | D3 |
| `new/backend/src/ARA.Infrastructure/HealthChecks/KeyVaultHealthCheck.cs` | Delete if D4 = no KV | D4 |
| `new/backend/src/ARA.Infrastructure/ARA.Infrastructure.csproj` | Drop `Azure.Security.KeyVault.Secrets` and `Azure.Identity` if D4 = no KV | D4 |
| `new/backend/src/ARA.Api/ARA.Api.csproj` | Drop `Azure.Extensions.AspNetCore.Configuration.Secrets` if D4 = no KV; drop `Microsoft.ApplicationInsights.AspNetCore` if D5 drops App Insights | D4, D5 |
| `new/backend/Dockerfile` | Delete if D1 picks IIS or Windows Service; keep if D1 picks Docker Desktop on Windows | D1 |
| `new/frontend/Dockerfile` + `new/frontend/nginx.conf` | Delete if D2 picks IIS; keep if D2 keeps containerization | D2 |
| `docs/ship/LOCAL_DEV_SECRETS.md` | Update to remove Key Vault wording if D4 retires KV | D4 |
| `docs/ship/HEALTH_AND_TELEMETRY.md` | Remove the Key Vault check section if D4 retires KV | D4 |
| `docs/SHIP_PLAN.md` | Apply all the retire / amend / add changes in one cohesive update | always |

---

## Sequence of execution (after decisions land)

1. **Pivot commit (one PR)** — update `SHIP_PLAN.md` with the retirements + amendments + new items above. Mark Item 6 and Item 8 `[RETIRED]` with a carry-forward pointer to 8a–8e. Don't touch source code yet — this is the planning record.
2. **Cleanup commit** — delete `infra/bicep/`, `scripts/Deploy-AzureInfrastructure.ps1`, `docs/ship/AZURE_PROVISIONING.md`, and any conditionally-removed code per the inventory above. Single PR titled something like `refactor: retire Azure deployment artifacts for on-prem pivot`.
3. **Code conditionals** (per D4/D5 outcomes) — strip Azure dependencies from `Program.cs`, csproj files, health checks. Should be small. One PR.
4. **New deployment artifacts (Item 8a + 8b)** — server-prep checklist + `scripts/Deploy-OnPremises.ps1`. PowerShell-only per CLAUDE.md. Drafted, not run. One PR.
5. **Runbook (Item 8c)** — `docs/ship/ON_PREM_DEPLOYMENT.md`. One PR.
6. **TLS / networking doc (Item 8d, only if D7 says reverse proxy)** — small, one PR or folded into 8c.
7. **Item 6 rewrite** — replace the Azure-flavored go-live checklist with the on-prem version. Sign-offs as we go through each line.
8. **First on-prem deploy** (manual, supervised) — when you say go.

---

## What stays untouched

These don't change:

- Backend application code (services, repos, controllers, middleware) — all on-prem-portable
- Frontend application code (the SPA itself; only `VITE_API_BASE` changes at deploy time)
- All SQL migrations under `scripts/sql/` — same schema either target
- Okta integration — cloud-hosted, agnostic to where the app runs
- PR validation CI (`.github/workflows/pr-validation.yml`) — pre-merge gates work the same
- Test suite (95 backend + 40 frontend tests, coverage gates)
- The four `[x]` items already on `dev` — Items 1, 2, 3, 4, 5, 7 all carry forward unchanged in spirit (with Item 2 amended for the new secret store and Item 5 amended if telemetry changes)

---

## Risks flagged

- **Don't strip Azure code until D4/D5 are settled.** If you keep App Insights or Key Vault, the existing wiring is correct and shouldn't be removed.
- **`LoggingEmailService` is already the default** per the 2026-04-28 sign-off — no change needed for email regardless of the pivot, unless D6 changes that.
- **Dev-tenant Okta values in CLAUDE.md still apply** for development against an on-prem dev box; only prod Okta tenant values matter for the on-prem prod target.
- **The Item 7 backend coverage gap** (≥80% target carried forward) is unaffected by this pivot — it was always a code-level gate, not deploy-related.
