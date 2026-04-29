# ARA Migration — Execution Plan

**Created:** 2026-04-27
**Author:** Claude (Opus 4.6) with Louis Hall
**Status:** SUPERSEDED — historical record only. The current source of truth for what's done and what's next is `docs/SHIP_PLAN.md`. The deployment direction described below (Azure Container Apps, Static Web App, Key Vault, Application Insights via KV) was retired on 2026-04-29 by the on-premises Windows Server pivot — see `docs/ship/ON_PREM_PIVOT_PLAN.md` (D1–D10) for the decisions and the SHIP_PLAN's Items 8a–8e for the replacement deployment artifacts.

> Read this file for context on what was decided in April 2026 during the original autonomous-execution phases. Do **not** treat any forward-looking statement here (e.g. "Phase 3.5 — Azure Container Apps Deployment") as current direction — it isn't.

---

## Plan Summary

| Phase | Scope | Milestones |
|-------|-------|------------|
| **Stabilization** | Commit ~30 in-flight files to a feature branch in logical groups | 5 commits |
| **Phase 1** | Database connectivity, missing stored procedures, schema alignment, test infrastructure | 8 work items |
| **Phase 2** | ARA workflow features: email, documents, CLIN, expiration, search, negation, integration tests | 8 work items |
| **Phase 3** | Hardening: coverage targets, FluentValidation, RFC 7807, deployment pipeline | 5 work items |

---

## Key Decisions Requiring Your Confirmation

These are choices with significant cost, scope, or architectural implications. I will not proceed until you confirm or override each one.

### Decision 2 — Integration Test Database Strategy

For end-to-end tests that hit a real database (Phase 1.3, Phase 2.1, Phase 2.5):

- **(A) Shared Azure SQL dev database** — uses the existing `hii-ara-dev` instance. Pro: matches production. Con: tests are non-deterministic, need cleanup, requires network.
- **(B) SQL Server LocalDB** — ships with Visual Studio on Windows. Pro: no network dependency, fast. Con: Windows-only, no Linux CI without Docker.
- **(C) Testcontainers + Docker** — spins up a disposable SQL Server container per test run. Pro: hermetic, CI-friendly, cross-platform. Con: requires Docker Desktop on dev machines, slower startup (~15s).

**Recommendation: (A) for now** — you already have the Azure SQL dev instance provisioned. Integration tests use a dedicated `ARA_Test` schema or a `[Test_]` prefix convention so they don't pollute dev data. We can migrate to Testcontainers later if CI demands it.
Answer: A

### Decision 3 — Email Provider

CLAUDE.md specifies automated email from `ara@hii-tsd.com`. **Options:**

- **(A) Azure Communication Services Email** — native Azure, simple REST API, fits the Azure-native stack.
- **(B) SendGrid** — widely used, good .NET SDK, free tier for dev.
- **(C) SMTP relay** — if HII already has an on-prem or cloud SMTP relay for `hii-tsd.com`.
- **(D) Stub with logging** — implement the `IEmailService` interface and log emails to the database `EmailLog` table. Wire a real provider later when IT provides credentials.

**Recommendation: (D) for Phase 2** — build the full `IEmailService` abstraction and email template system, but dispatch to a `LoggingEmailService` that writes to `EmailLog`. This unblocks all workflow development. Swap to a real provider when credentials are available. The CLAUDE.md rule "What to Never Include Without Being Asked — New Azure resources" supports deferring the real provider.
Answer: D

### Decision 4 — Document Storage

`DocumentsTab.tsx` currently registers metadata only. **Options:**

- **(A) Azure Blob Storage** — the obvious choice for Azure-hosted apps. Requires a storage account.
- **(B) Local file system** — simple for dev, not viable for production.
- **(C) Stub with metadata only** — keep current behavior, wire blob storage when the Azure resource is provisioned.

**Recommendation: (C) for now, with (A) architecture** — build `IDocumentStorageService` with an `AzureBlobDocumentStorageService` implementation and a `LocalFileDocumentStorageService` for dev. But don't create Azure resources (per CLAUDE.md restrictions). The metadata-only path works for all workflow testing.
Answer: C

### Decision 5 — ARA Expiration Scheduling Mechanism

ARAs must auto-expire based on the PM-entered date. **Options:**

- **(A) ASP.NET Core Background Service (`IHostedService`)** — runs a periodic check (e.g., every hour) inside the API process. Pro: no additional infrastructure. Con: single-instance concern if scaled horizontally.
- **(B) Azure Function with Timer Trigger** — runs on a cron schedule outside the API. Pro: scales independently. Con: new Azure resource (violates CLAUDE.md "What to Never Include Without Being Asked").
- **(C) Database-level scheduled job** — SQL Agent job or a stored procedure called by the existing `usp_AraGetUpcomingExpirations` pattern.

**Recommendation: (A)** — `AraExpirationHostedService` running every hour. At the scale of this application (internal workflow tool, not high-traffic), a single background service is sufficient. The stored procedure `usp_AraUpdateStatus` already exists. If horizontal scaling becomes a concern later, a distributed lock (or migration to Azure Function) is straightforward.
Answer: A, but make the cadence once an hour.

### Decision 6 — Frontend Test Installation

Vitest and React Testing Library are not in `package.json`. Installing them means adding npm packages, which CLAUDE.md says "What to Never Include Without Being Asked — Any npm package not already in package.json."

**I am asking now: may I install `vitest`, `@testing-library/react`, `@testing-library/jest-dom`, `@testing-library/user-event`, and `jsdom` as dev dependencies?** These are required for the test infrastructure described in CLAUDE.md's own Testing Conventions section.
Answer: Yes, you may install these specicfic packages

---

## Things I Will Decide Autonomously

These are decisions within the scope of the approved plan that I will make, document in `docs/DECISIONS.md`, and not ask about:

- Stored procedure naming, parameter conventions, and SQL structure (following existing `usp_[Entity][Action]` pattern)
- Mapping between `Threshold` table and `ApprovalMatrixEntry` domain entity (column aliasing in SPs)
- Schema alignment for `Delegation` and `RejectionReason` tables (adding missing columns via migration scripts)
- Test class organization and naming (following CLAUDE.md conventions)
- Service method signatures and DTO shapes (following existing patterns)
- Frontend component structure and hook patterns (following existing conventions)
- Email template HTML/text content (following the business rules in CLAUDE.md)
- Order of execution within a phase (I'll follow the dependency graph below)
- Whether to split a commit or combine related changes (following "one concern per commit")

---

## Things I Will Stop and Ask About

- Any change that would alter the database schema of tables already in production use
- Any security-sensitive decision (auth scopes, CORS origins, secret storage)
- Any deviation from the Approval & Threshold Matrix business rules
- Any conflict between CLAUDE.md / user guide and what I observe in the code
- Any new Azure resource provisioning
- Any change to the Okta configuration
- Anything that would meaningfully change the scope of this plan

---

## Stabilization — Commit In-Flight Work

**Branch:** `feature/phase2-workflow-foundation`
**Base:** `dev`

The ~30 modified and untracked files group into 5 logical concerns. Each gets its own commit.

### Commit 1 — Domain model updates (entities + enums)

**Files:**
- `ARA.Domain/Entities/Ara.cs` — updated entity with all workflow fields
- `ARA.Domain/Entities/ApprovalRecord.cs` — added fields for delegation tracking
- `ARA.Domain/Entities/ApprovalMatrixEntry.cs` — new entity
- `ARA.Domain/Entities/Delegation.cs` — new entity
- `ARA.Domain/Entities/RejectionReason.cs` — new entity
- `ARA.Domain/Enums/AraStatus.cs` — updated status values
- `ARA.Domain/Enums/AraTab.cs` — new enum for rejection tab targeting
- `ARA.Domain/Enums/RiskCategory.cs` — updated categories

**Message:** `feat(domain): add entities and enums for approval routing, delegation, and rejection`

### Commit 2 — Repository layer (interfaces + implementations + DI)

**Files:**
- `ARA.Domain/Repositories/IUserRepository.cs` — added role-based query methods
- `ARA.Domain/Repositories/IApprovalMatrixRepository.cs` — new interface
- `ARA.Domain/Repositories/IDelegationRepository.cs` — new interface
- `ARA.Domain/Repositories/IRejectionReasonRepository.cs` — new interface
- `ARA.Infrastructure/Repositories/UserRepository.cs` — new method implementations
- `ARA.Infrastructure/Repositories/ApprovalRecordRepository.cs` — updated queries
- `ARA.Infrastructure/Repositories/ApprovalMatrixRepository.cs` — new implementation
- `ARA.Infrastructure/Repositories/DelegationRepository.cs` — new implementation
- `ARA.Infrastructure/Repositories/RejectionReasonRepository.cs` — new implementation
- `ARA.Infrastructure/InfrastructureServiceExtensions.cs` — register new repos

**Message:** `feat(infrastructure): add repositories for approval matrix, delegation, and rejection reasons`

### Commit 3 — Approval routing service + tests

**Files:**
- `ARA.Application/Approval/IApprovalRoutingService.cs` — new interface
- `ARA.Application/Approval/ApprovalRoutingService.cs` — full routing engine
- `ARA.Application/Approval/ApprovalAuthorization.cs` — authorization result DTO
- `ARA.Application/Approval/ApprovalStepResult.cs` — step result DTO
- `ARA.Application.Tests/Approval/ApprovalRoutingServiceTests.cs` — 16 tests
- `ARA.Application/ApplicationServiceExtensions.cs` — register ApprovalRoutingService

**Message:** `feat(approval): implement approval routing service with delegation support and tests`

### Commit 4 — Delegation and rejection reason features

**Files:**
- `ARA.Application/Delegation/IDelegationService.cs`
- `ARA.Application/Delegation/DelegationService.cs`
- `ARA.Application/Delegation/DelegationDto.cs`
- `ARA.Application/Delegation/CreateDelegationRequest.cs`
- `ARA.Application/RejectionReason/IRejectionReasonService.cs`
- `ARA.Application/RejectionReason/RejectionReasonService.cs`
- `ARA.Application/RejectionReason/RejectionReasonDto.cs`
- `ARA.Api/Controllers/DelegationsController.cs`
- `ARA.Api/Controllers/RejectionReasonsController.cs`
- `ARA.Application/ApplicationServiceExtensions.cs` — register DelegationService, RejectionReasonService

**Message:** `feat(workflow): add delegation management and rejection reason lookup endpoints`

### Commit 5 — ARA service updates + controller changes

**Files:**
- `ARA.Application/Ara/IAraService.cs` — updated interface with workflow methods
- `ARA.Application/Ara/AraService.cs` — updated service with submit/approve/reject logic
- `ARA.Api/Controllers/ArasController.cs` — updated controller with workflow endpoints

**Message:** `feat(ara): add workflow action endpoints for submit, approve, reject, cancel, and negate`

### Commit 6 — Documentation

**Files:**
- `CLAUDE.md` — updated with resolved ambiguities and Phase 2 unblocked status

**Message:** `docs(config): update CLAUDE.md with resolved ambiguities and approval matrix`

**Note:** The `.claude/` and `answers/` directories will not be committed — `.claude/` is IDE configuration and `answers/` is working notes, neither belongs in the repo.

---

## Phase 1 — Foundation

### 1.1 — Missing Stored Procedures

**Scope:** Write `scripts/sql/005_approval_delegation_rejection_procs.sql` containing the stored procedures that the infrastructure repositories already call but that don't exist in `003_stored_procedures.sql`.

**Missing SPs to create:**
- `usp_ApprovalMatrixGetActive` — SELECT from `Threshold` table, alias columns to match `ApprovalMatrixEntry` entity
- `usp_ApprovalMatrixGetForAmount` — SELECT from `Threshold` WHERE `LowThreshold <= @Amount`, ordered by `JobTitle.AppOrder`
- `usp_DelegationGetActiveForUser` — SELECT active delegation where `DelegateFromId = @DelegatorUserId` and date range is current
- `usp_DelegationGetActiveForDelegatee` — SELECT active delegations where `DelegateToId = @DelegateeUserId`
- `usp_DelegationGetAllActive` — SELECT all currently active delegations
- `usp_DelegationCreate` — INSERT into `Delegation`, return `SCOPE_IDENTITY()`
- `usp_DelegationDeactivate` — UPDATE to set `EndDate = GETUTCDATE()` (soft deactivate)
- `usp_RejectionReasonGetAllActive` — SELECT all from `RejectionReason`
- `usp_RejectionReasonGetById` — SELECT by ID

**Dependencies:** None
**Test strategy:** Verified by integration tests in 1.3
**Acceptance criteria:** All repository calls resolve to valid SPs; `dotnet build` succeeds

### 1.2 — Schema Alignment Migration

**Scope:** Write `scripts/sql/006_schema_alignment.sql` to fix mismatches between domain entities and database tables.

**Changes:**
1. **Threshold table** — Add `SequenceOrder INT` column (maps to `ApprovalMatrixEntry.SequenceOrder`). Seed with values matching the 10-role approval matrix from CLAUDE.md.
2. **Delegation table** — Add computed `IsActive` column or handle via SP logic (active = `StartDate <= GETUTCDATE() AND EndDate >= GETUTCDATE()`). Alias `DelegateFromId`/`DelegateToId` in SPs to match entity names.
3. **RejectionReason table** — Add `DisplayOrder INT` and `IsInactive BIT DEFAULT 0` columns.
4. **Threshold seed data** — Populate the 10 approval matrix rows per CLAUDE.md specification.
5. **RejectionReason seed data update** — Replace current 6 generic reasons with the 7 specified in CLAUDE.md (Supporting Documentation is Insufficient, Incorrect CLIN Number Used, etc.).

**Dependencies:** 1.1 (SPs reference these columns)
**Test strategy:** Run scripts against dev database, verify with SELECT queries
**Acceptance criteria:** All domain entities map cleanly to database columns via Dapper; no runtime column-not-found errors

### 1.3 — Integration Test Infrastructure (Backend)

**Scope:** Create an integration test project that runs against a real database.

**Files:**
- `new/backend/tests/ARA.Infrastructure.Tests/ARA.Infrastructure.Tests.csproj`
- `new/backend/tests/ARA.Infrastructure.Tests/TestDatabaseFixture.cs` — shared fixture that reads a test connection string, runs migration scripts, provides `IDbConnectionFactory`
- `new/backend/tests/ARA.Infrastructure.Tests/Repositories/` — one test class per repository

**Approach:**
- Connection string from environment variable `ARA_TEST_CONNECTION_STRING` (falls back to `appsettings.Test.json` which is gitignored)
- `IClassFixture<TestDatabaseFixture>` for shared setup
- Each test class wraps operations in a transaction that is rolled back after each test (no permanent state changes)
- Initial test classes: `UserRepositoryTests`, `ApprovalMatrixRepositoryTests`, `DelegationRepositoryTests`

**Dependencies:** 1.1, 1.2
**Test strategy:** Self-testing — the tests ARE the deliverable
**Acceptance criteria:** `dotnet test` passes for all integration tests with a valid connection string; tests skip gracefully when no connection string is provided

### 1.4 — Unit Test Scaffolding (Backend)

**Scope:** Add unit test classes for all existing services that lack tests.

**Test classes to create in `ARA.Application.Tests/`:**
- `Ara/AraServiceTests.cs`
- `Delegation/DelegationServiceTests.cs`
- `RejectionReason/RejectionReasonServiceTests.cs`
- `Category/CategoryServiceTests.cs`
- `JobTitle/JobTitleServiceTests.cs`
- `User/UserServiceTests.cs`
- `ClinEntry/ClinEntryServiceTests.cs`
- `Document/DocumentServiceTests.cs`
- `Sections/AraPmSectionServiceTests.cs`
- `Sections/AraControllerSectionServiceTests.cs`
- `ApprovalRecord/ApprovalRecordServiceTests.cs`

**Pattern per class:** Happy path, null/empty inputs, business rule violations. Mock at repository layer only.

**Dependencies:** None (unit tests mock all dependencies)
**Test strategy:** `dotnet test` in the `ARA.Application.Tests` project
**Acceptance criteria:** Every public service method has at least one test. All tests pass.

### 1.5 — Frontend Test Infrastructure

**Scope:** Install test dependencies and create Vitest configuration.

**Changes:**
- Install dev dependencies: `vitest`, `@testing-library/react`, `@testing-library/jest-dom`, `@testing-library/user-event`, `jsdom`
- Create `new/frontend/vitest.config.ts`
- Create `new/frontend/src/test/setup.ts` (RTL matchers, cleanup)
- Add `"test"` script to `package.json`
- Create initial test: `src/hooks/useAuth.test.ts` (verifies test infrastructure works)

**Dependencies:** Decision 6 approval
**Acceptance criteria:** `npm run test` passes

### 1.6 — Frontend Unit Test Scaffolding

**Scope:** Add tests for hooks, components, and utilities.

**Priority test files:**
- `src/hooks/useAras.test.ts` — query hooks with MSW or manual QueryClient mocking
- `src/hooks/useCategories.test.ts`
- `src/lib/ara-helpers.test.ts` — pure function tests
- `src/lib/format.test.ts` — pure function tests
- `src/lib/validation/createAraSchema.test.ts` — Zod schema validation tests
- `src/components/Ara/WorkflowActionBar.test.tsx` — permission logic
- `src/components/Ara/RejectDialog.test.tsx` — form validation
- `src/components/Ara/ClinWorksheet.test.tsx` — calculation logic

**Dependencies:** 1.5
**Acceptance criteria:** All tests pass; core business logic (helpers, validation, permission checks) has coverage

### 1.7 — Verify Full Build

**Scope:** Run all checks end-to-end before moving to Phase 2.

- `dotnet build` — zero errors, zero warnings
- `dotnet test` — all unit + integration tests pass
- `npm run build` — frontend builds
- `npm run test` — frontend tests pass
- `npm run lint` — no lint errors

**Dependencies:** 1.1–1.6
**Acceptance criteria:** Clean pass on all five commands

---

## Phase 2 — ARA Workflow

### Dependency Graph

```
2.4 Email Service (stub)
    |
    v
2.1 End-to-End Workflow -----> 2.5 Approval Matrix Integration Tests
    |         |        \
    v         v         v
2.3 Documents  2.2 CLIN   2.8 Negation
    |
    v
2.6 ARA Expiration
    |
    v
2.7 Search & Dashboard
```

**Execution order (maximizing parallelism):**
- **Wave A:** 2.4 (Email stub) — everything else depends on email notifications
- **Wave B:** 2.2 (CLIN), 2.3 (Documents), 2.8 (Negation) — independent of each other, all depend on 2.4
- **Wave C:** 2.1 (End-to-end workflow), 2.5 (Approval integration tests) — depend on 2.2, 2.3, 2.4
- **Wave D:** 2.6 (Expiration), 2.7 (Search & Dashboard) — depend on stable workflow

### 2.1 — End-to-End Workflow Testing

**Scope:** Verify the full PM -> CA -> Controller -> Approver chain works against real database with all business rules enforced.

**Files touched:**
- `ARA.Application/Ara/AraService.cs` — audit and fix submit/approve/reject methods against CLAUDE.md business rules
- `ARA.Api/Controllers/ArasController.cs` — ensure all workflow endpoints match frontend service expectations
- `ARA.Infrastructure.Tests/Workflow/AraWorkflowIntegrationTests.cs` — new integration test class

**Business rules to verify:**
- Save-before-action gate (PM must save before submit)
- Section lock-down on submission (read-only after submit)
- Rejection returns to PM, increments revision, unlocks all sections
- Sequential approval chain (one approver at a time)
- Delegation substitution works end-to-end
- Cancellation restricted to PM only

**Dependencies:** Phase 1 complete, 2.4 (email stub — so workflow transitions don't fail on missing email service)
**Test strategy:** Integration tests with real database; each test creates an ARA and walks it through the full workflow
**Acceptance criteria:** All workflow integration tests pass; every business rule from CLAUDE.md "Business Rules — Always Enforce These" section is covered

### 2.2 — CLIN Worksheet

**Scope:** Complete the CLIN worksheet backend and verify frontend integration.

**Files touched:**
- `ARA.Application/ClinEntry/ClinEntryService.cs` — add business rule enforcement:
  - Each CLIN can only be used once per ARA
  - Auto-calculate Total Cost, Total Fees, Total
  - Soft warning when CLIN total exceeds ARA amount
- `ARA.Api/Controllers/ClinsController.cs` — add validation, return soft-warning flag
- `scripts/sql/` — verify `usp_ClinCreate`, `usp_ClinUpdate`, `usp_ClinDelete` exist and are correct
- `ARA.Application.Tests/ClinEntry/ClinEntryServiceTests.cs` — business rule tests

**Frontend:**
- `ClinWorksheet.tsx` — already functional; verify soft-warning display
- Interest Impact field — verify read-only $0.00 display
- Expected Burn Rate — verify free numeric entry

**Dependencies:** Phase 1 complete
**Test strategy:** Unit tests for service logic; manual verification of frontend behavior
**Acceptance criteria:** CLIN uniqueness enforced; totals auto-calculated; soft warning displayed when over ARA amount; Interest Impact locked to $0.00

### 2.3 — Document Upload

**Scope:** Implement document upload with PDF validation, size limits, and requirement tagging.

**Backend files:**
- `ARA.Application/Document/IDocumentStorageService.cs` — new interface
- `ARA.Application/Document/DocumentService.cs` — add validation (PDF only, 5MB max), requirement checking
- `ARA.Infrastructure/Storage/LocalFileDocumentStorageService.cs` — dev implementation (saves to local temp directory)
- `ARA.Api/Controllers/DocumentsController.cs` — update to accept `IFormFile` upload
- `ARA.Application.Tests/Document/DocumentServiceTests.cs` — validation tests

**Stored procedures:**
- Verify `usp_AraAttachmentCreate`, `usp_AraAttachmentDelete`, `usp_AraAttachmentGetByAraId` are complete
- Add SP for tagging: `usp_AraAttachmentRequirementLinkCreate`, `usp_AraAttachmentRequirementLinkDelete`

**Frontend files:**
- `DocumentsTab.tsx` — replace text inputs with file picker (`<input type="file" accept=".pdf">`)
- Add 5MB client-side validation
- Add requirement tag selection based on risk category and role

**Business rules:**
- Required docs for Non-Early Start CA submission (per CLAUDE.md document requirements table)
- Optional docs for Early Start at both CA and Controller stages
- One PDF can satisfy multiple requirements; multiple PDFs can satisfy one requirement

**Dependencies:** Phase 1 complete
**Test strategy:** Unit tests for validation; frontend manual test for upload flow
**Acceptance criteria:** PDF-only enforcement; 5MB limit; tagging works; CA blocked from submitting Non-Early Start without required docs

### 2.4 — Email Notifications

**Scope:** Build the email service abstraction and logging implementation.

**Backend files:**
- `ARA.Application/Email/IEmailService.cs` — interface with `SendAsync(EmailMessage)` method
- `ARA.Application/Email/EmailMessage.cs` — record with `To`, `Subject`, `HtmlBody`, `TextBody`, `AraId`, `ActionType`
- `ARA.Application/Email/EmailTemplateService.cs` — builds email content from templates per action type
- `ARA.Infrastructure/Email/LoggingEmailService.cs` — writes to `EmailLog` table instead of sending
- `ARA.Infrastructure/Repositories/EmailLogRepository.cs` — Dapper insert to `EmailLog`
- `scripts/sql/` — verify `EmailLog` table schema, add `usp_EmailLogCreate` SP

**Email events (from CLAUDE.md):**
- PM signs and submits → notify CA
- CA submits → notify Controller
- Controller submits → notify first approver
- Approver approves → notify PM, Controller, prior approvers; separate email to next approver
- Any rejection → notify all prior actors
- Negation → notify all creation and approval parties
- Cancellation → notify PM, CA, admin

**All emails include:** link to ARA, summary of ARA details, action taken, who took it.
**Sender:** `ara@hii-tsd.com`

**Dependencies:** None — this is the first item in Phase 2
**Test strategy:** Unit tests for template generation; integration test verifying `EmailLog` entries are created on workflow transitions
**Acceptance criteria:** Every workflow transition produces correct `EmailLog` entries with proper recipients, subject, and body

### 2.5 — Approval Matrix Routing Integration Tests

**Scope:** End-to-end tests verifying the approval routing engine against the real `Threshold` table.

**Files:**
- `ARA.Infrastructure.Tests/Approval/ApprovalRoutingIntegrationTests.cs`

**Test scenarios:**
- ARA under $500K routes through steps 4-7 only (Portfolio Leader -> Contract Director -> Group Finance Manager -> Business Group President)
- ARA at $500K+ routes through all 10 steps including Finance VP, SVP Contracts, MTC COO
- Delegation substitution: delegatee can act in place of delegator
- Division/approval group matching: approver only sees ARAs matching their `approve_grp`
- OpsVP is PM-selected, not auto-routed
- MTC COO approval is always final
- Single approver cannot satisfy multiple threshold levels

**Dependencies:** 2.1, Phase 1 complete
**Test strategy:** Integration tests against real database with seeded Threshold data
**Acceptance criteria:** All 7 scenarios pass; matrix changes (adding/removing rows from Threshold) correctly alter routing

### 2.6 — ARA Expiration Auto-Transition

**Scope:** Background service that automatically expires ARAs past their expiration date.

**Files:**
- `ARA.Api/BackgroundServices/AraExpirationHostedService.cs` — `BackgroundService` subclass, runs every hour
- `ARA.Application/Ara/IAraService.cs` — add `ExpireOverdueArasAsync()` method
- `ARA.Application/Ara/AraService.cs` — implement: query ARAs where `ExpirationDate < GETUTCDATE()` and status is active, update each to Expired
- `scripts/sql/` — add `usp_AraExpireOverdue` SP (bulk update)
- `ARA.Application.Tests/Ara/AraServiceTests.cs` — test expiration logic

**Business rules:**
- Only active ARAs expire (Draft, PendingCA, PendingController, PendingApproval)
- Once expired, ARA is permanently read-only
- No mechanism to extend an expiration date

**Dependencies:** 2.1 (stable workflow status model)
**Test strategy:** Unit test for service logic; integration test with ARA set to past date
**Acceptance criteria:** ARAs with past expiration dates transition to Expired; expired ARAs reject all further actions

### 2.7 — Search & Dashboard Backend

**Scope:** Complete backend query support for the Search page, Dashboard, and My Action List.

**Backend files:**
- `ARA.Application/Ara/AraService.cs` — add search, dashboard, and action list methods
- `ARA.Application/Ara/AraSearchRequest.cs` — search criteria DTO with filters
- `scripts/sql/` — verify/enhance existing SPs:
  - `usp_AraGetPendingForUser` — My Action List (already exists, verify correctness)
  - `usp_AraSearchById` — Quick Search (already exists)
  - Add `usp_AraSearch` — full search with filters (status, category, date range, org, contract, text)
  - `usp_AraGetUpcomingExpirations` — Dashboard expirations (already exists)
  - Add `usp_AraGetDashboardSummary` — counts by status for dashboard cards

**Pagination:** All list endpoints return `PagedResult<T>` with `Items`, `TotalCount`, `Page`, `PageSize`. Default page size: 25. Max: 100.

**Performance:** Add indexes if query plans show table scans on common filter columns (Status, CategoryId, CreatedAt, AssignedPmId).

**Dependencies:** 2.1 (stable status model)
**Test strategy:** Unit tests for filtering logic; integration tests for SP correctness
**Acceptance criteria:** All frontend list pages receive data; search returns correct results for all filter combinations; pagination works

### 2.8 — Negation Flow

**Scope:** Implement the CA-only negation action on approved/exported ARAs.

**Backend files:**
- `ARA.Application/Ara/AraService.cs` — add `NegateAraAsync()` with role and status validation
- `ARA.Api/Controllers/ArasController.cs` — verify `POST /api/aras/{araId}/negate` endpoint
- `ARA.Application.Tests/Ara/AraServiceTests.cs` — negation tests

**Business rules:**
- Only CA role can negate
- Only ARAs in Approved or Exported status can be negated (Exported is legacy; since JAMIS export is OBE, "Approved" is the terminal positive state — I will treat Approved ARAs as negatable and document this decision)
- Status changes to "Negated" immediately
- Email sent to all creation and approval parties

**Frontend:**
- `WorkflowActionBar.tsx` — already has `canNegate` logic for Exported status; update to also allow for Approved status
- `ArchivedPage.tsx` — verify negation action is accessible from archived view

**Dependencies:** 2.4 (email notifications)
**Test strategy:** Unit tests for role/status validation; integration test for full negation flow
**Acceptance criteria:** CA can negate Approved ARAs; non-CA users are blocked; email sent; status updates immediately

---

## Phase 3 — Hardening

### 3.1 — Backend Test Coverage

**Scope:** Fill coverage gaps identified after Phase 2. Target: 80% line coverage on `ARA.Application` and `ARA.Infrastructure` projects.

**Approach:**
- Run coverage report with `dotnet test --collect:"XPlat Code Coverage"` + ReportGenerator
- Identify uncovered paths in service and repository code
- Add tests for edge cases: concurrent approval attempts, delegation expiry during approval, malformed inputs

**Dependencies:** Phase 2 complete
**Acceptance criteria:** 80% line coverage; all critical business rule paths covered

### 3.2 — Frontend Test Coverage

**Scope:** Fill frontend coverage gaps. Target: 70% line coverage (lower than backend due to UI rendering complexity).

**Priority areas:**
- All workflow action paths in `WorkflowActionBar`
- Form validation in `CreateAraPage` wizard steps
- CLIN calculation edge cases
- Error and loading states in all data-fetching components

**Dependencies:** Phase 2 complete
**Acceptance criteria:** 70% line coverage; all user-facing workflow paths covered

### 3.3 — FluentValidation on All Endpoints

**Scope:** Add request validators for every API endpoint.

**Files:**
- `ARA.Api/Validators/` — one validator per request type
- `CreateAraRequestValidator`, `UpdateAraRequestValidator`, `CreateClinRequestValidator`, etc.
- Shared base validators for common patterns (positive ID, non-empty string, date range)

**Approach:**
- FluentValidation is already registered in `Program.cs` via `AddValidatorsFromAssembly`
- Add `[FromBody]` model validators that fire automatically via the ASP.NET pipeline
- Validation errors return RFC 7807 Problem Details format (ties into 3.4)

**Dependencies:** Phase 2 complete
**Acceptance criteria:** Every POST/PUT endpoint has a validator; invalid requests return 400 with Problem Details body

### 3.4 — RFC 7807 Problem Details

**Scope:** Implement global exception handling middleware that returns consistent error responses.

**Files:**
- `ARA.Api/Middleware/ProblemDetailsMiddleware.cs` — catches unhandled exceptions, maps to Problem Details
- `ARA.Api/Middleware/ValidationProblemDetailsFactory.cs` — custom factory for FluentValidation errors
- Update `Program.cs` to register middleware

**Error mapping:**
- `Result.Failure` → 400 Bad Request with Problem Details
- FluentValidation failures → 400 with validation errors array
- Unauthorized → 401
- Forbidden → 403
- Not Found → 404
- Unhandled exception → 500 with generic message (details logged, not exposed)

**Dependencies:** 3.3 (validation errors must flow through the same format)
**Acceptance criteria:** All error responses follow RFC 7807; no raw exception details leak to clients

### 3.5 — Azure Container Apps Deployment

**Scope:** Dockerfile, CI/CD pipeline, and ACA configuration.

**Files:**
- `new/backend/Dockerfile` — multi-stage build (.NET publish + runtime image)
- `new/frontend/Dockerfile` — multi-stage build (npm build + nginx)
- `.github/workflows/deploy.yml` or `azure-pipelines.yml` — CI/CD pipeline
- `infra/` — Bicep templates for ACA environment, container apps, secrets

**Configuration:**
- Backend reads connection string and Okta config from ACA secrets (mapped to env vars)
- Frontend build embeds Okta client ID and API URL at build time
- Health check endpoint: `GET /health` (already configured)
- CORS: configured per environment

**Note:** This item will require creating Azure resources, which CLAUDE.md restricts. I will prepare the configuration files and Dockerfiles but will ask before provisioning any Azure infrastructure.

**Dependencies:** Phase 2 complete, 3.3, 3.4
**Acceptance criteria:** `docker build` succeeds for both backend and frontend; CI pipeline defined; ACA configuration documented

---

## Progress Tracking

During execution, I will maintain:

- **`docs/PROGRESS.md`** — updated after each completed item with: what was done, decisions made, files changed, tests added, what's next
- **`docs/DECISIONS.md`** — autonomous decisions with rationale, created when first needed
- **Commits** — one per logical unit of work, pushed to the feature branch frequently

### Phase Boundary Protocol

At the end of each phase:
1. Run the full test suite (`dotnet test` + `npm run test` + `npm run build` + `npm run lint`)
2. Fix any failures before proceeding
3. Post a summary to the conversation: what was built, test coverage, decisions logged, deferred items
4. Proceed to the next phase without waiting for explicit approval (unless I've flagged a blocker)

---

## Estimated Execution Order

```
STABILIZATION
  Commit 1: Domain model updates
  Commit 2: Repository layer
  Commit 3: Approval routing service + tests
  Commit 4: Delegation + rejection reason features
  Commit 5: ARA service updates
  Commit 6: Documentation

PHASE 1
  1.1  Missing stored procedures
  1.2  Schema alignment migration
  1.3  Integration test infrastructure
  1.4  Unit test scaffolding (backend)
  1.5  Frontend test infrastructure
  1.6  Frontend unit test scaffolding
  1.7  Full build verification
  --- Phase 1 summary ---

PHASE 2
  2.4  Email notifications (stub)
  2.2  CLIN worksheet        |
  2.3  Document upload        | parallel where possible
  2.8  Negation flow          |
  2.1  End-to-end workflow tests
  2.5  Approval matrix integration tests
  2.6  ARA expiration
  2.7  Search & dashboard
  --- Phase 2 summary ---

PHASE 3
  3.1  Backend test coverage
  3.2  Frontend test coverage
  3.3  FluentValidation
  3.4  RFC 7807 Problem Details
  3.5  Azure Container Apps deployment
  --- Phase 3 summary ---
```
