# AGENTS.md — ARA Migration Project

Quick-start context for AI agents. Read `CLAUDE.md` for full conventions. This file covers traps and high-signal workflow.

---

## What This Is

ColdFusion → .NET 10 + React migration. Legacy app is read-only in `legacy/`. New stack: `new/backend/` (.NET Clean Architecture + Dapper) and `new/frontend/` (Vite + React 19 + TypeScript strict).

**Authority on behavior:** `legacy/ARAUserGuideV2.md` is the single source of truth. Before implementing any feature, read the relevant section. If unclear, stop and ask — never assume.

---

## Timeout / Token Rules

This machine times out frequently; interrupted work must be restartable with minimal re-work. These are hard rules, no exceptions:

- **Smallest possible steps.** Every plan is an ordered checklist of tiny, independently completable steps. Each step does one thing and leaves the repo in a known state.
- **Restartable via the plan file.** Track progress as a checklist inside the plan `.md` (`- [ ]` / `- [x]`). After each step, mark it done. On restart, read only the plan file to find the next unchecked step — do not re-explore or re-read files already covered by completed steps.
- **Minimize tokens.** Do not re-read files or re-run discovery you have already done. Prefer narrow, targeted reads/edits over large ones. Batch independent tool calls.
- **Minimize tool/API output.** Request and return the least data needed (narrow file reads with offsets/limits, scoped searches, quiet build output, no dumping large files). This applies to agent tool calls, not app runtime behavior.
- **No guessing.** If a step is ambiguous, stop and ask rather than assume.

---

## Critical Non-Negotiables

- **No inline SQL.** Always use stored procedures. Create new ones in `scripts/sql/003_stored_procedures.sql` (idempotent `CREATE OR ALTER`). Deploy with `.\scripts\Invoke-AraMigration.ps1`.
- **No `var` in C#.** Explicit types only.
- **No `any` in TypeScript.** Strict mode enforced.
- **Never modify** `legacy/`, `old/`, or `components/ui/` (shadcn vendored).
- **Result<T> pattern** for service methods. Never throw exceptions for business failures. `Result<T>.Failure("message")`.
- **Scripts:** PowerShell only. Never bash.
- **Git:** Never commit automatically. Always wait for explicit instruction.

---

## Commands (Windows PowerShell)

### Quick Start

```powershell
# Start backend (from repo root)
.\start-backend.ps1
# → http://localhost:5081

# Start frontend (from repo root)
.\start-frontend.ps1
# → http://localhost:5173 (proxies /api to backend)
```

### Backend (from `new/backend/`)

```powershell
dotnet build ARA.slnx                            # Build
dotnet format ARA.slnx --verify-no-changes       # Format check (CI gate)
dotnet test ARA.slnx                             # Run all tests
dotnet run --project src/ARA.Api/ARA.Api.csproj  # Start API manually
```

### Frontend (from `new/frontend/`)

```powershell
npm ci                    # Install deps
npm run dev               # Dev server
npm run lint              # Lint (CI gate)
npm run build             # Build
npm run test              # All tests
npm run test:coverage     # Coverage (≥70% on src/lib/**)
```

### Database

```powershell
# From repo root
.\scripts\Invoke-AraMigration.ps1

# Local SQL Server:
.\scripts\Invoke-AraMigration.ps1 -ConnectionString "Server=localhost;Database=ARA_New;Integrated Security=True;TrustServerCertificate=True;"

# Azure SQL (after az login):
az login
.\scripts\Invoke-AraMigration.ps1
```

Migrations: `scripts/sql/001_tables.sql`, `002_seed_data.sql`, `003_stored_procedures.sql` (all idempotent).

---

## Stack Structure

### Backend (Clean Architecture)

`new/backend/` — .NET 10, Dapper, stored procedures only

- **ARA.Api** — Controllers (thin), FluentValidation, `DevAuthenticationHandler`, hosted services
- **ARA.Application** — Services (business logic), DTOs, `Result<T>` pattern
- **ARA.Domain** — Entities, enums, repository interfaces (zero dependencies)
- **ARA.Infrastructure** — Dapper repos, SQL connection factory
- **Tests** — xUnit in `ARA.Application.Tests` + `ARA.Infrastructure.Tests`

Connection string: `AraDatabase` in appsettings or `dotnet user-secrets` locally.

### Frontend (React 19 + TypeScript)

`new/frontend/` — Vite + Tailwind CSS v4 + shadcn/ui v3

- **`components/ui/`** — shadcn base (never modify)
- **`components/[Feature]/`** — feature components (`Ara/`, `CreateAra/`, `layout/`, `shared/`)
- **`hooks/`** — custom hooks (prefix `use[Resource]`)
- **`services/`** — API wrappers (not hooks)
- **`lib/`** — validation, formatting, constants
- **`store/`** — Zustand global state
- **`types/`** — shared interfaces

Path alias: `@/` → `src/`

State: TanStack Query for server state, Zustand for global, `useState` for local UI.

---

## Git Workflow

- **NEVER push directly to `dev`.** No exceptions. All work must be committed on a feature branch and merged via merge/pull request.
- **Feature branch names must NOT contain a hyphen (`-`).** No exceptions. Use another separator (e.g. `_` or camelCase), for example `addDeliveryOffice` or `add_delivery_office`, never `add-delivery-office`.
- **Branches:** `[type]/[short_description]` (e.g., `feature/pm_tab`, `fix/clin_calculation`)
  - Types: `feature`, `fix`, `data`, `infra`, `refactor`, `test`, `docs`, `chore`
- **Commits:** Conventional Commits enforced by CI (`commitlint.config.cjs`)
  - Format: `<type>(<scope>): <description>` (≤72 chars, lowercase, no period)
  - Types: `feat`, `fix`, `data`, `infra`, `refactor`, `test`, `docs`, `chore`, `style`
  - Body: Reference ColdFusion files replaced when applicable
  - **NEVER include `Co-authored-by` trailers or any references to AI models, tools, or assistants in commit messages**
- **Never commit:** secrets, connection strings, build artifacts, `node_modules`, `bin/`, `obj/`
- **Never commit automatically:** Always wait for explicit instruction

---

## CI Checks (.github/workflows/pr-validation.yml)

All three jobs must pass:

1. **Backend:** Build Release + `dotnet format --verify-no-changes` + tests (≥35% line coverage)
2. **Frontend:** Lint + build + tests (≥70% coverage on `src/lib/**`)
3. **Commitlint:** All commits match Conventional Commits

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