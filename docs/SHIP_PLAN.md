# ARA Ship Plan

**Created:** 2026-04-28
**Branch this lives on:** `docs/ship-plan`
**Source of truth for what's done and what's next on the road to production.**

When a future session opens this file, it can resume work without re-deriving context: read the file top to bottom, find the next `[ ]` item in execution order, confirm prior items are `[x]`, review carry-forward notes, and start.

---

## Status Legend

- `[ ]` Not started
- `[~]` In progress
- `[x]` Complete
- `[DEFERRED]` Intentionally postponed

---

## Global Rules

- **Commit format:** Conventional Commits per `CLAUDE.md` (`<type>(<scope>): <description>`). The previously-floated `AB#[number]` convention was retired on 2026-04-28 — do not use it.
- **One item at a time, in the order listed.** Do not start Item N+1 until Item N is `[x]`.
- **Test discipline (Items 1–6):** all coverage work is deferred to Item 7. During Items 1–6, write a test only when the test is the only way to validate that the item itself is functional (e.g. a smoke check that proves Costpoint import landed rows). Bug-fix tests for regressions caught during Items 1–6 are also allowed but kept minimal.
- **Completing an item:** flip `[ ]` → `[x]`, add a `Completed:` line to the item with the date and commit SHA(s), append any unexpected findings or follow-ups to **Carry-forward notes**, and add a line to the **Completion log** at the bottom.
- **Starting an item:** re-read this file, confirm prior items are `[x]`, review Carry-forward notes, then flip Item N to `[~]` in a first commit before doing any work.
- **Scope discipline:** if you discover something mid-item that changes scope, stop and update this plan rather than silently expanding. The plan is the contract.

---

## Items (in execution order)

### Item 1 — Costpoint import [ ]

- **What it means:** Build a manually-triggered import process that pulls Org, CLIN, and Contract Number reference data from a Costpoint backup file and lands it in the local Azure SQL tables that ARA queries (`Org`, `Clin`, `ContractNumber` or whatever the existing schema names them).
- **Why it blocks ship:** Without this data, no ARA can be created. Org and Contract Number validation queries the local DB; CLIN worksheet pre-populates from the local DB. Empty tables = non-functional application.
- **Required outcome:**
  - PowerShell-only import script (per CLAUDE.md "All scripts that are created my only be powershell") that takes the backup file path as a parameter and lands rows via stored procedures
  - Idempotent — re-running against the same backup yields the same final state with no duplicates and no destructive churn
  - An import-log table (or row in an existing config table) capturing the timestamp of the last successful import — required by Item 5 (data freshness health check)
  - A smoke check that confirms a non-zero row count and that an ARA can be created end-to-end against the imported reference data
- **Files / components touched:**
  - `scripts/import/Import-CostpointData.ps1` (new) — main import script
  - `scripts/import/data/` (new, gitignored) — folder where the backup file is expected
  - `scripts/sql/00X_costpoint_reference_tables.sql` (new) — confirms target tables exist; adds `CostpointImportLog` table for freshness tracking
  - `scripts/sql/usp_OrgUpsert.sql`, `usp_ClinUpsert.sql`, `usp_ContractNumberUpsert.sql`, `usp_CostpointImportLog_RecordSuccess.sql` (new SPs)
  - `docs/ship/COSTPOINT_IMPORT.md` (new) — invocation guide and expected file path
  - `.gitignore` — add `scripts/import/data/` if not already covered
- **Dependencies:** None.
- **Out of scope for this item:**
  - Live Costpoint API integration (CLAUDE.md: ARA does not communicate with Costpoint directly)
  - Scheduled / automated import (manual trigger is sufficient)
  - Production data validation (this validates against the stale backup only — production import is part of Item 6)
  - Test coverage beyond the smoke check (full coverage is Item 7)
  - UI for triggering the import
- **Acceptance checklist:**
  - [ ] Backup file path documented; user has confirmed file is in place at the expected path
  - [ ] Import script runs to completion against the stale backup with zero errors
  - [ ] Re-running the script against the same backup produces no row changes (proven via row count + idempotency check)
  - [ ] `Org`, `Clin`, and `ContractNumber` tables show non-zero row counts after import
  - [ ] `CostpointImportLog` records the successful run with timestamp
  - [ ] Smoke test: an ARA can be created in dev that validates against an imported Org and Contract Number, and the CLIN worksheet pre-populates from imported CLIN data
  - [ ] Invocation documented in `docs/ship/COSTPOINT_IMPORT.md`
- **Completion update instruction:** When done, flip the heading to `[x]`, add a `Completed: YYYY-MM-DD — <commit SHA(s)>` line below the checklist, append any findings to Carry-forward notes, and add a Completion log line.

---

### Item 2 — Secrets extraction (Okta + connection string → Key Vault) [ ]

- **What it means:** Move Okta clientId / issuer and the database connection string out of `appsettings*.json` and any committed env files. Wire Azure Key Vault references via Container App managed identity for production. Local dev uses .NET user-secrets and `.env.local`.
- **Why it blocks ship:** Secrets in source = security incident risk and an audit blocker. Connection string injection is also a runtime requirement — `appsettings.json` currently has an empty connection string, so this is also a "boots in prod" issue.
- **Required outcome:**
  - All secrets removed from tracked source files
  - Backend reads from Key Vault via managed identity at boot in production; falls back to user-secrets in `Development`
  - Frontend Okta clientId injected at build time via env var (Dockerfile already accepts these as build args — confirm wired through)
  - Local dev setup documented; verification step boots the app with zero secrets in source
- **Files / components touched:**
  - `new/backend/src/ARA.Api/Program.cs` — add `AddAzureKeyVault` configuration source, gated on environment
  - `new/backend/src/ARA.Api/appsettings.json` — strip secrets, add `KeyVaultUri` config key
  - `new/backend/src/ARA.Api/appsettings.Production.json` — strip any secrets present
  - `new/frontend/src/config/okta-config.ts` (or equivalent) — read from `import.meta.env.VITE_OKTA_*` instead of hardcoded literals
  - `new/frontend/.env.example` (new) — document required env vars
  - `docs/ship/LOCAL_DEV_SECRETS.md` (new) — user-secrets and `.env.local` setup
  - `.gitignore` — confirm `.env.local`, `appsettings.Production.json`, etc. are covered
- **Dependencies:** None.
- **Out of scope for this item:**
  - Provisioning the Key Vault resource itself (Item 8 — deferred Azure provisioning)
  - CI/CD secret injection (Item 3 covers pipeline; secrets extraction happens here)
  - Test coverage of secrets-loading code (Item 7)
- **Acceptance checklist:**
  - [ ] Grep of `new/` for known Okta clientIds, issuers, and connection-string fragments returns zero hits in tracked files
  - [ ] Backend boots locally using `dotnet user-secrets` with no secrets in any tracked file
  - [ ] Frontend builds locally using `.env.local` with no secrets in any tracked file
  - [ ] Production config wires Key Vault references in code (resource provisioning deferred to Item 8)
  - [ ] Local dev setup documented in `docs/ship/LOCAL_DEV_SECRETS.md`
- **Completion update instruction:** Flip to `[x]`, add `Completed:` line with SHA(s), append findings to Carry-forward notes, add Completion log entry.

---

### Item 3 — CI/CD pipeline (PR validation) [ ]

- **What it means:** Add automated PR validation. Gates: build backend, build frontend, lint, format check, commit-message check (Conventional Commits). **No test execution gate yet — that lands in Item 7.** Branch protection on `dev` and `main` to require this check.
- **Pipeline location:** GitHub Actions (`.github/workflows/`). Repo is hosted on GitHub (`lhallhiiai/aramigration`); `gh` CLI is already in use; Azure DevOps is not present in the repo. Calling this out per the planning brief.
- **Why it blocks ship:** No automated PR validation = broken code can land. Items 4–7 all add code; we want a baseline gate before that pile gets bigger.
- **Required outcome:**
  - `.github/workflows/pr-validation.yml` runs on PRs targeting `dev` and `main`
  - Gates: `dotnet build -c Release`, `dotnet format --verify-no-changes`, `npm ci && npm run build`, `npm run lint`
  - Commit-message check enforces Conventional Commits (commitlint or equivalent)
  - Branch protection on `dev` and `main` requires this workflow to pass before merge (config performed in GitHub UI; documented as a checklist)
- **Files / components touched:**
  - `.github/workflows/pr-validation.yml` (new)
  - `.commitlintrc.json` or `commitlint.config.js` (new) — if going with the npm-based check
  - `package.json` — add commitlint dev deps if needed (CLAUDE.md normally requires asking before adding deps; this is a CI tool addition, ask in-flight if needed)
  - `docs/ship/CI_CD.md` (new) — branch protection setup checklist for the GitHub UI
- **Dependencies:** None.
- **Out of scope for this item:**
  - Test execution gate (Item 7)
  - Build/push of container images and any deploy step (Item 8 — deferred)
  - Azure DevOps pipelines
- **Acceptance checklist:**
  - [ ] Workflow file present at `.github/workflows/pr-validation.yml`
  - [ ] Workflow runs successfully on a test PR (build backend, build frontend, lint, format check)
  - [ ] Conventional Commits check enforced (fails on non-conforming commit message)
  - [ ] Branch protection on `dev` requires the workflow to pass before merge (documented; settings applied in GH UI)
  - [ ] Branch protection on `main` mirrors `dev`
- **Completion update instruction:** Flip to `[x]`, add `Completed:` line with SHA(s), append findings to Carry-forward notes, add Completion log entry.

---

### Item 4 — User provisioning (Okta JIT + admin onboarding) [ ]

- **What it means:** When an authenticated Okta user hits the app and has no row in the local `Users` table, create one automatically using token claims. Provide an admin-onboard fallback for cases where JIT cannot run (e.g. background processes that need a user record before any sign-in). **Authorization rule for production: any user granted access to the application in Okta gets access — there is no per-user gate inside the app itself.**
- **GCC High quirk:** On `hii.okta-gov.com`, `credentials.provider.*` filter paths are disabled. Any directory queries must scope by app integration, not by provider filter. Note this in code comments and `docs/ship/USER_PROVISIONING.md`.
- **Why it blocks ship:** Today, `CurrentUserService` logs a warning when an authenticated user has no DB row — silent failure. In production, real users sign in successfully but get nothing useful. Manual `INSERT` per hire is unacceptable.
- **Required outcome:**
  - JIT provisioning fires after authentication on the first request from an unknown user, INSERTs a `Users` row using token claims (`sub` → `ExternalUserId`, email → `Email`, name → `DisplayName`, etc.)
  - Idempotent — runs only when the user is missing
  - Admin-onboard endpoint (or PowerShell script) that seeds a user from sub/email/name without first-login
  - Claim mapping documented
  - Silent-failure path in `CurrentUserService` removed; missing user becomes a hard failure with clear log
- **Files / components touched:**
  - `new/backend/src/ARA.Application/User/UserProvisioningService.cs` (new)
  - `new/backend/src/ARA.Api/Middleware/JitUserProvisioningMiddleware.cs` (new) — fires after auth, before controllers
  - `new/backend/src/ARA.Api/Controllers/AdminUsersController.cs` (new) — admin onboard endpoint
  - `new/backend/src/ARA.Application/User/CurrentUserService.cs` (update) — remove silent-failure warning
  - `scripts/sql/usp_UserProvision.sql` (new) — idempotent insert
  - `docs/ship/USER_PROVISIONING.md` (new) — claim map + GCC High quirk + admin-onboard guide
- **Dependencies:** None (auth is already wired).
- **Out of scope for this item:**
  - Per-user app-level authorization (rule: Okta access = app access)
  - Role assignment automation — JIT creates the user with whatever default role is policy; role changes are manual / handled elsewhere
  - Test coverage (Item 7)
- **Acceptance checklist:**
  - [ ] First-time Okta sign-in creates a `Users` row automatically; second sign-in does not
  - [ ] Admin onboard endpoint creates a `Users` row from `sub`/`email`/`name` without requiring sign-in
  - [ ] Claim → column mapping documented
  - [ ] Silent-failure warning paths removed; missing user becomes a hard 500 with clear log
  - [ ] GCC High quirk (no `credentials.provider.*` filters) noted in code and docs
  - [ ] Smoke test: sign in as a new Okta test user, verify `Users` row is created and ARA pages load
- **Completion update instruction:** Flip to `[x]`, add `Completed:` line with SHA(s), append findings to Carry-forward notes, add Completion log entry.

---

### Item 5 — Application Insights + real health checks [ ]

- **What it means:** Wire Application Insights into the backend with the connection string sourced from Key Vault. Replace the placeholder `/health` endpoint with a real readiness probe: database connectivity, Key Vault reachability, Costpoint-import-data freshness, and Okta metadata reachability. Keep `/health/live` cheap.
- **Why it blocks ship:** No telemetry = blind in production. The default `/health` returns 200 even when the DB is down; operators have nothing to monitor.
- **Required outcome:**
  - App Insights configured via Key Vault-sourced connection string
  - `/health/live` — cheap, returns 200 if process is up; no dependency calls
  - `/health/ready` — runs real checks, returns degraded JSON when any check fails
  - Custom checks: SQL connectivity, Key Vault reachability, Costpoint-data freshness (date of last successful import from Item 1's `CostpointImportLog`), Okta OIDC discovery endpoint reachability
- **Files / components touched:**
  - `new/backend/src/ARA.Api/Program.cs` — add App Insights, register health checks, map `/health/live` and `/health/ready`
  - `new/backend/src/ARA.Infrastructure/HealthChecks/SqlConnectivityHealthCheck.cs` (new)
  - `new/backend/src/ARA.Infrastructure/HealthChecks/KeyVaultHealthCheck.cs` (new)
  - `new/backend/src/ARA.Infrastructure/HealthChecks/CostpointDataFreshnessHealthCheck.cs` (new)
  - `new/backend/src/ARA.Infrastructure/HealthChecks/OktaMetadataHealthCheck.cs` (new)
  - `scripts/sql/usp_CostpointImportLog_GetLatest.sql` (new) — supports the freshness check
- **Dependencies:** Item 2 (Key Vault), Item 1 (Costpoint import populates the freshness signal).
- **Out of scope for this item:**
  - Dashboards, alert rules, log queries (operations setup, not code)
  - Test coverage (Item 7)
- **Acceptance checklist:**
  - [ ] App Insights connection string read from Key Vault — no fallback to source
  - [ ] `/health/live` returns 200 with no dependencies checked
  - [ ] `/health/ready` returns JSON with per-check status; degrades when any dependency is unreachable
  - [ ] All four custom checks present: SQL, Key Vault, Costpoint freshness, Okta metadata
  - [ ] Manual test: kill DB connectivity → `/health/ready` reports unhealthy; restore → healthy
- **Completion update instruction:** Flip to `[x]`, add `Completed:` line with SHA(s), append findings to Carry-forward notes, add Completion log entry.

---

### Item 6 — Production readiness for ARA creation [ ]

- **What it means:** Consolidation item. Capture every config / setting / data prerequisite that must be true in production for an ARA to actually be created end-to-end, then verify each one. The output of this item is a dated production go-live checklist embedded below.
- **Why it blocks ship:** Items 1–5 are individual building blocks. This is the integration step — the moment we stop and verify they all align before flipping production traffic.
- **Required outcome:** The checklist below is fully `[VERIFIED]` (with date and verifier) before this item flips to `[x]`. Anything that cannot be verified must be explicitly resolved (deferred with sign-off, or completed) before flip.
- **Files / components touched:**
  - `docs/SHIP_PLAN.md` (this file) — checklist below filled in
  - Possibly `docs/ship/PROD_GO_LIVE.md` if the runbook grows beyond what fits here
- **Dependencies:** Items 1, 2, 3, 4, 5.
- **Out of scope for this item:**
  - Test coverage (Item 7)
  - Items in the deferred section (Item 8)

#### Production go-live checklist (fill in during execution)

- [ ] Costpoint import has run against PRODUCTION data (not the stale backup); row counts match expected; verifier / date: ___
- [ ] Key Vault references resolve in the prod Container App at boot (no startup errors); verifier / date: ___
- [ ] Okta app integration in PROD tenant points at the prod hostname (CORS allowed origins, redirect URIs, audience); verifier / date: ___
- [ ] `Users` table reachable; JIT provisioning enabled and verified with one prod test user; verifier / date: ___
- [ ] Approval matrix seed data loaded (10-row matrix per CLAUDE.md); verifier / date: ___
- [ ] Email notifications point at a real sender — `LoggingEmailService` swapped for the chosen real provider with creds in Key Vault. If IT creds are still pending, this check is signed off as deferred only with explicit user approval; verifier / date: ___
- [ ] `/health/ready` reports healthy on prod across all four checks; verifier / date: ___
- [ ] Application Insights is ingesting telemetry from prod; verifier / date: ___
- [ ] CORS allowlist includes the prod frontend hostname and excludes test hostnames; verifier / date: ___
- [ ] Frontend `VITE_API_BASE` (or equivalent) points at the prod API hostname; verifier / date: ___
- [ ] One end-to-end smoke ARA created in prod by a test PM, walked PM → CA → Controller → all approvers, and Approved; verifier / date: ___

- **Completion update instruction:** Flip to `[x]` only when every checklist line above is verified or formally signed off as deferred. Add `Completed:` line with SHA(s), append findings to Carry-forward notes, add Completion log entry.

---

### Item 7 — Test coverage (deferred until end) [ ]

- **What it means:** All previously-deferred test work lands here: backend xUnit unit + integration coverage gap-fill, frontend Vitest coverage gap-fill, coverage targets, and the test gate added to the CI pipeline from Item 3.
- **Discipline reminder:** During Items 1–6, write tests only as smoke checks proving the item itself works, plus regression tests for bugs caught along the way. All other coverage work lands here.
- **Why it blocks ship:** Without sufficient coverage and a CI gate, regressions can land silently after launch. This is the last gate before the system is trusted.
- **Required outcome:**
  - Backend line coverage ≥ 80% on `ARA.Application` and `ARA.Infrastructure`
  - Frontend line coverage ≥ 70%
  - CI runs `dotnet test` and `npm run test` on every PR; failure blocks merge
  - CI fails the PR when coverage drops below threshold
  - All critical workflow paths have integration coverage
- **Files / components touched:**
  - `new/backend/tests/**` — gap-fill unit and integration tests
  - `new/frontend/src/**.test.ts(x)` — gap-fill component, hook, and util tests
  - `.github/workflows/pr-validation.yml` — add `dotnet test` and `npm run test` gates plus coverage threshold check
  - `coverlet.runsettings` (new) — backend coverage config
  - `vitest.config.ts` (update) — coverage config
- **Dependencies:** Item 3 (CI pipeline must exist to add the test gate).
- **Out of scope for this item:**
  - Performance / load tests
  - Mutation testing
  - E2E tests beyond what is already established
- **Acceptance checklist:**
  - [ ] Backend line coverage ≥ 80% on `ARA.Application` and `ARA.Infrastructure`
  - [ ] Frontend line coverage ≥ 70%
  - [ ] CI runs `dotnet test` and `npm run test` on every PR; failure blocks merge
  - [ ] CI fails the PR when coverage drops below threshold
  - [ ] All critical workflow paths (PM submit, CA submit, Controller submit, approve, reject, delegation, expiration, negation) have integration tests
- **Completion update instruction:** Flip to `[x]`, add `Completed:` line with SHA(s), append findings to Carry-forward notes, add Completion log entry.

---

### Item 8 — Known deferrals [DEFERRED]

These were already deferred prior to this ship plan. Listed here as a continuity register from `docs/PROGRESS.md` so nothing is lost. Each entry notes its disposition.

- **Backend test coverage gap-fill** [DEFERRED] — Originally deferred from Phase 3.1 (`docs/PROGRESS.md`). Resolved by Item 7 of this plan.
- **Frontend test coverage gap-fill** [DEFERRED] — Originally deferred from Phase 3.2. Resolved by Item 7 of this plan.
- **Real email provider swap (`LoggingEmailService` → SendGrid / Azure Communication Services)** [DEFERRED] — Blocked on IT providing credentials. Picked up by Item 6 once creds exist; if creds are still outstanding when Item 6 runs, that line is signed off as deferred only with explicit user approval, and prod ships with logging-only email (or doesn't ship).
- **Azure Container Apps resource provisioning** [DEFERRED] — Items 2, 5, and 6 assume the Container App, Key Vault, and Application Insights resources exist. Provisioning these resources is gated on user authorization per CLAUDE.md "What to Never Include Without Being Asked: New Azure resources." Bicep / IaC templates may be drafted under this item but not applied until the user authorizes Azure resource creation.

---

## Carry-forward notes

Append findings, follow-ups, and gotchas here as items complete. Keep entries dated.

- *(no entries yet)*

---

## Completion log

Append `Item N completed YYYY-MM-DD — <commit SHA(s)>` lines here as items finish.

- *(no entries yet)*
