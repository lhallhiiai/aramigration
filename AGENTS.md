# AGENTS.md — ARA Migration Project

Quick-start context for AI agents working in this repository.

---

## What This Is

ColdFusion → .NET 10 + React migration. The legacy app is read-only reference in `legacy/`. New stack is in `new/backend/` (.NET) and `new/frontend/` (React + TypeScript).

**Authority on behavior:** `legacy/ARAUserGuideV2.md` is the single source of truth. Before implementing any feature, read the relevant section. If behavior is unclear or missing from the guide, stop and ask — never assume.

---

## Stack & Structure

### Backend (.NET 10)

- **Location:** `new/backend/`
- **Solution:** `ARA.slnx` (XML solution format)
- **Architecture:** Clean Architecture — API → Application → Domain → Infrastructure
- **Projects:**
  - `ARA.Api` — Controllers, thin, no business logic
  - `ARA.Application` — Services, DTOs, `Result<T>` pattern (no exceptions for business failures)
  - `ARA.Domain` — Entities, enums, repository interfaces (no dependencies)
  - `ARA.Infrastructure` — Dapper repos, connection factory
  - `ARA.Application.Tests` + `ARA.Infrastructure.Tests` — xUnit tests
- **Data access:** Dapper only, **always use stored procedures** (never inline SQL)
- **Connection string:** `AraDatabase` in appsettings (use `dotnet user-secrets` locally)
- **Features by domain:**
  - `Application/Ara/` — core ARA workflow
  - `Application/Approval/` — approver chain logic
  - `Application/Clin/` — CLIN worksheet (Non-Early Start only)
  - `Application/Document/` — PDF upload
  - `Application/Email/` — notifications
  - Other: `Category`, `Delegation`, `JobTitle`, `RejectionReason`, `Users`

### Frontend (React + TypeScript)

- **Location:** `new/frontend/`
- **Stack:** Vite + React 19 + TypeScript strict + Tailwind CSS v4 + shadcn/ui v3
- **Path alias:** `@/` → `src/`
- **Folders:**
  - `components/ui/` — shadcn base components (never modify directly)
  - `components/[Feature]/` — feature components (e.g., `Ara/`, `CreateAra/`)
  - `hooks/` — custom hooks (always named `use[Resource]`)
  - `services/` — API fetch wrappers (not hooks)
  - `types/` — shared interfaces
  - `store/` — Zustand global state
  - `pages/` — routing
  - `lib/` — utilities (validation, formatting)
- **State:** TanStack Query for server state, Zustand for global client state, `useState` for local UI only
- **API proxy:** `/api` → `http://localhost:5081` (Vite dev server proxy in `vite.config.ts`)

---

## Commands

### Backend

```powershell
cd new/backend

# Build
dotnet build ARA.slnx

# Format check (CI enforces this)
dotnet format ARA.slnx --verify-no-changes

# Test (all)
dotnet test ARA.slnx

# Run API (uses user-secrets for connection string)
dotnet run --project src/ARA.Api/ARA.Api.csproj
# API runs on http://localhost:5081
```

### Frontend

```powershell
cd new/frontend

# Install
npm ci

# Dev server (proxies /api to backend)
npm run dev

# Lint (CI enforces this)
npm run lint

# Build
npm run build

# Test (all)
npm run test

# Test with coverage (CI checks ≥70% on lib/ modules)
npm run test:coverage
```

### Database

```powershell
# Run migrations (from repo root)
.\scripts\Invoke-AraMigration.ps1

# Local SQL Server example:
.\scripts\Invoke-AraMigration.ps1 -ConnectionString "Server=localhost;Database=ARA_New;Integrated Security=True;TrustServerCertificate=True;"

# Azure SQL (uses az CLI account):
az login
.\scripts\Invoke-AraMigration.ps1
```

Migrations are in `scripts/sql/`: `001_tables.sql`, `002_seed_data.sql`, `003_stored_procedures.sql` (all idempotent).

---

## Non-Negotiables

From `CLAUDE.md`:

- **C#:** No `var`. Explicit types. XML doc comments on all public members. No business logic in controllers. `Result<T>` for service methods (never throw for business failures).
- **TypeScript:** No `any`. Strict mode. No inline styles (Tailwind only). Props interface named `[Component]Props` in same file.
- **Data access:** Stored procedures only (never inline SQL). Parameterized always.
- **Testing:** xUnit (backend), Vitest + React Testing Library (frontend). Test naming: `MethodName_StateUnderTest_ExpectedBehavior`. Mock only at repository layer.
- **Scripts:** PowerShell only (never bash).
- **Read-only zones:** Never touch `legacy/`, `old/`, or `components/ui/` (shadcn vendored code).

---

## Git Workflow

- **Branches:** `[type]/[short-description]` (e.g., `feature/pm-tab`, `fix/clin-calculation`)
  - Types: `feature`, `fix`, `data`, `infra`, `refactor`, `test`, `docs`, `chore`
- **Commits:** Conventional Commits enforced by CI (`commitlint.config.cjs`)
  - Format: `<type>(<scope>): <description>` (≤72 chars, lowercase, no period)
  - Types: `feat`, `fix`, `data`, `infra`, `refactor`, `test`, `docs`, `chore`, `style`
  - Body: Reference ColdFusion files replaced when applicable
- **Never commit:** secrets, connection strings, build artifacts, `node_modules`, `bin/`, `obj/` (see `.gitignore`)
- **Never commit automatically:** Always wait for explicit instruction before running `git commit`

---

## CI/CD

GitHub Actions: `.github/workflows/pr-validation.yml`

**Backend job:**
- Build Release
- Format check (`dotnet format --verify-no-changes`)
- Test with coverage (≥35% line threshold in `Test-CoverageThreshold.ps1`)

**Frontend job:**
- Lint (`npm run lint`)
- Build
- Test with coverage (≥70% line/branch/function/statement on `src/lib/**`)

**Commitlint job:**
- Validates every commit in PR against Conventional Commits

All checks must pass before merge.

---

## Domain Quirks

These differ from typical CRUD apps — always enforce:

- **Two ARA types:** "Authority to Spend Only" vs. "Authority to Spend with Revenue Recognition"
- **Two risk paths:**
  - **Non-Early Start** — uses Contract Number, requires CA docs, **requires CLIN worksheet** at Controller stage
  - **Early Start** (Pre-Contract Costs) — uses Contract Number, CA docs optional, **no CLIN worksheet**
- **Sequential workflow:** PM → CA → Controller → Approver(s). Each stage locks previous sections. Rejection resets to PM.
- **Org, Contract Number, CLIN are free-text** (no validation against Costpoint/ERP). Legacy behavior, maintained.
- **CLIN worksheet rules (Non-Early Start only):**
  - One CLIN number per entry (no duplicates within an ARA)
  - CLIN funding cap is a **soft warning** (warn if Cost + Fee > ARA Amount, but allow proceed)
  - Interest Impact: legacy field, always $0.00 (display read-only)
  - Expected Burn Rate: manual dollar entry, no validation
- **Document upload:** PDF only, 5 MB max, no count limit. One PDF can satisfy multiple requirements; multiple PDFs can satisfy one requirement.
- **PM questions:** 6 questions, all amounts (the $50K threshold no longer applies per product owner override)
- **Approver routing:** Sequential, determined by Approval & Threshold Matrix (see user guide). Not all approvers participate on every ARA (threshold-based).
- **Session timeout:** 3 hours

**Ambiguities resolved:** See `CLAUDE.md` → "Ambiguities and Gaps — Resolution Status" for the 12 resolved questions (approval matrix, PM/CA questions, CLIN rules, delegation, etc.).

---

## Azure Config

- Subscription: Azure subscription 1
- Region: West US 2
- Resource Group: ARA-Dev-Work
- Naming: `hii-ara-dev-[resource]`

**Okta (Test):**
- Domain: `https://hii-test-admin.oktapreview.com/`
- API Client ID: `0oawygfqavWdJX7Nw1d7`
- Issuer: `https://hii-test.oktapreview.com/oauth2/default`
- Audience: `api://default`
- Frontend SPA Client ID: `0oawyh822mSqLuAqu1d7`

---

## Development Workflow

1. **Before implementing a feature:**
   - Read the relevant section in `legacy/ARAUserGuideV2.md`
   - State which section applies and summarize intended behavior before writing code
   - If the guide doesn't cover a scenario, say: "This scenario is not covered in the user guide. Based on the ColdFusion code it appears to [behavior]. Please confirm before I proceed."

2. **When creating stored procedures:**
   - Add to `scripts/sql/003_stored_procedures.sql` (idempotent `CREATE OR ALTER`)
   - Name pattern: `usp_[Entity][Action]` (e.g., `usp_AraGetById`, `usp_AraPmSectionUpsert`)
   - Deploy: `.\scripts\Invoke-AraMigration.ps1`

3. **When adding backend features:**
   - Controller (thin) → Service (business logic, returns `Result<T>`) → Repository (interface in Domain, impl in Infrastructure)
   - Add xUnit tests in `ARA.Application.Tests` or `ARA.Infrastructure.Tests`

4. **When adding frontend features:**
   - Component in `components/[Feature]/` + custom hook in `hooks/` + API wrapper in `services/`
   - Use TanStack Query for server state
   - Vitest test in `[Component].test.tsx`

5. **Before submitting PR:**
   - Backend: `dotnet format ARA.slnx` + `dotnet test ARA.slnx`
   - Frontend: `npm run lint` + `npm run build` + `npm run test:coverage`
   - Verify commit messages pass `commitlint.config.cjs`

---

## Reference Docs

- **CLAUDE.md** — full coding conventions, architecture, git rules, domain terminology (924 lines)
- **OUTSTANDINGWORK.md** — current project status, Phase 1 (complete), Phase 2 (complete), remaining work
- **legacy/ARAUserGuideV2.md** — authoritative source of truth for all application behavior (408 lines)
- **PRODUCT_OWNER_QUESTIONS.md** — resolved ambiguities (reference if business rules are unclear)

---

## Common Pitfalls

- **Don't assume behavior** — always check user guide first
- **Don't write inline SQL** — always create/use stored procedures
- **Don't return exceptions for business failures** — use `Result<T>.Failure("message")`
- **Don't modify `components/ui/`** — shadcn components are vendored
- **Don't use `any` in TypeScript** — strict mode enforced
- **Don't commit without instruction** — always wait for explicit "commit this"
- **Don't skip CLIN worksheet for Non-Early Start** — it's required at Controller stage
- **Don't validate Org/Contract/CLIN against external systems** — they're free-text per legacy behavior
