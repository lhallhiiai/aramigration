# ARA Migration — Outstanding Work

Last updated: 2026-05-23

## Current State

- **Phase 1**: COMPLETE — Foundation (toolchain, scaffold, DB connectivity, infrastructure, domain)
- **Phase 2**: COMPLETE — ARA Workflow API backend (Application + Infrastructure + API layers)
- **Phase 3**: IN PROGRESS — Frontend GUI implementation and polish

### What's Running Now

The full stack runs locally in dev mode (Okta auth disabled; `DevAuthenticationHandler` active):

- Backend: `dotnet run --project src/ARA.Api/ARA.Api.csproj` → `http://localhost:5081`
- Frontend: `npm run dev` → `http://localhost:5173`
- Start scripts: `scripts\start-backend.ps1` / `scripts\start-frontend.ps1` (can be run from any directory)

### Frontend — What Exists

All pages, components, hooks, services, and types are scaffolded with real (non-stub) implementations:

**Pages** (`new/frontend/src/pages/`):

- `ActionListPage` — My Action List tab + See All ARAs tab, AraTable with TanStack Query
- `DashboardPage` — Expiration table + status count cards by workflow stage
- `CreateAraPage` — 4-step wizard: Step1 (risk category), Step2 (contract info), Step3 (role assignment), Step4 (review + submit)
- `AraDetailPage` — Tabbed detail view: Summary, PM Section, Controller Section, Documents, Approval Cycle + WorkflowActionBar
- `SearchPage` — Debounced search input → AraTable results
- `ArchivedPage` — Archived/negated ARAs list
- `SystemInfoPage` — Approval matrix + delegation info
- `NotFoundPage`, `LoginCallbackPage`

**Components** (`new/frontend/src/components/`):

- `Ara/`: `AraTable`, `AraDetailHeader`, `AraStatusBadge`, `AraSummaryTab`, `PmSectionTab`, `ControllerSectionTab`, `DocumentsTab`, `ApprovalCycleTab`, `WorkflowActionBar`, `ClinWorksheet`, `RejectDialog`
- `CreateAra/`: `Step1RiskCategory`, `Step2ContractInfo`, `Step3RoleAssignment`, `Step4Summary`, `StepIndicator`
- `layout/`: `AppLayout`, `AppSidebar`, `TopBar`, `QuickSearch`
- `shared/`: `EmptyState`, `ErrorState`, `LoadingState`
- `EnvironmentBanner` — color-coded environment indicator (Dev/Test/Prod); in place and wired into AppLayout
- `RequireAuth`, `ErrorBoundary`

**Hooks** (`new/frontend/src/hooks/`): `useAras`, `useAuth`, `useApprovals`, `useCategories`, `useClins`, `useDocuments`, `useJobTitles`, `useSections`, `useUsers`

**Services** (`new/frontend/src/services/`): `araService`, `approvalService`, `categoryService`, `clinService`, `documentService`, `jobTitleService`, `sectionService`, `userService`

**Types** (`new/frontend/src/types/`): `ara`, `approval`, `clin`, `document`, `category`, `user`, `sections`, `jobTitle`, `enums`

**Lib**: `api-client`, `format`, `ara-helpers`, `constants`, `environment-config`, `okta-config`, `query-client`, `validation/createAraSchema`

**Store**: `uiStore` (Zustand)

### Backend — What Exists

All Clean Architecture layers are fully implemented:

- **ARA.Api**: Controllers for `Aras`, `Approvals`, `Categories`, `Clins`, `Delegations`, `Documents`, `Environment`, `JobTitles`, `RejectionReasons`, `Users`, `AdminUsers`; FluentValidation validators for all inputs; `DevAuthenticationHandler` (dev-mode bypass); `JitUserProvisioningMiddleware`; `AraExpirationHostedService` (background expiration)
- **ARA.Application**: Services + DTOs for all domains; `Result<T>` pattern; `ApprovalRoutingService` + `ApprovalRecordService`; `AraEmailBuilder` + email event types; M365 SMTP via MailKit (`M365SmtpEmailService`)
- **ARA.Domain**: All entities (`Ara`, `AraPmSection`, `AraControllerSection`, `ClinEntry`, `AraDocument`, `ApprovalRecord`, `ApprovalMatrixEntry`, `Delegation`, `User`, `Category`, `JobTitle`, `RejectionReason`); all repository interfaces; all enums
- **ARA.Infrastructure**: All repository implementations (Dapper); `SqlConnectionFactory`; `LoggingEmailService` (dev stub); `OktaMetadataHealthCheck`; `SqlConnectivityHealthCheck`

---

## Active Focus: GUI Rework (Phase 3)

**Completed (2026-05-23): Dashboard Pass 5 — aligned PENDING ACTION panel with legacy canonical rows.**
Six state rows now match legacy: PM (Draft/1), Contracts (PendingCA/2), Controller (PendingController/3), Approval Chain (PendingApproval/4), Rejected (Cancelled/9 — proxy pending dedicated status), Approved (Approved/5). Column renamed Stage→State. Count cells rendered as plain text with TODO for `/action-list?status=` filter (route not yet wired). `useNavigate` removed from panel. Chart and table share single `rows` aggregation — identical values guaranteed.
Files: `DashboardPage.tsx`.

**Completed (2026-05-23): Dashboard Pass 4 — replaced per-record Nearest Expirations table with bucketed summary.**
`CRITICAL ARA EXPIRATIONS` panel now shows a 3-column summary table (Expires in… / Count / Sum of Amounts) driven by the same `EXPIRATION_BUCKETS` constant as the chart. Dropped the `> 30 days` bucket from both chart and table so chart and table are always in sync. Removed unused `format`, `getRiskCategoryLabel`, `formatExpiry`, `daysSeverityClass`, `formatDaysLabel` dead code.
Files: `DashboardPage.tsx`.

**Completed (2026-05-23): Dashboard Pass 3 — chart stacked above table in both panels.**
Both `PendingActionPanel` and `ExpirationPanel` changed from inner `md:grid-cols-2` side-by-side split to vertical chart-over-table layout. Chart height 260px; table body scrollable at `max-h-[480px]` with sticky `<thead>`. Outer `xl:grid-cols-2` panel grid unchanged.
Files: `DashboardPage.tsx`.

**Completed (2026-05-23): Expiration panel fixes — table gutters, date format (MMM d, yyyy), days severity coloring, histogram chart replacing per-reference bars.**
Files: `index.css` (danger/warning tokens), `DashboardPage.tsx` (ExpirationPanel).

**Completed (2026-05-23): Dashboard + layout HII brand modernisation.**
Files changed: `index.css` (tokens), `AppLayout.tsx` (full-width header restructure), `TopBar.tsx` (80px navy header + identity chip), `AppSidebar.tsx` (white sidebar, navy active state, grouped nav, QuickSearch in footer), `QuickSearch.tsx` (JAMIS ID copy fixed), `DashboardPage.tsx` (two-panel layout with Recharts bar charts), `components/shared/SectionHeading.tsx` (new), `package.json` (recharts added).
Pre-existing lint failure in shadcn-generated `use-mobile.ts` was not introduced by this work.

### GUI Pages — Status and Known Gaps

| Page | Status | Known Gaps |
| --- | --- | --- |
| ActionListPage | Functional scaffold | Visual polish; no empty-state illustration |
| DashboardPage | **Pass 5 complete** — HII brand frame, chart-over-table in both panels, bucketed expiration summary, canonical 6-row pending state table | Count values are plain text (TODO: wire `/action-list?status=` filter param) |
| CreateAraPage | Functional scaffold — 4-step wizard | Step logic, validation wiring, CA tab missing on AraDetailPage |
| AraDetailPage | Functional scaffold — tabs wired | CA tab absent (only PM + Controller sections exist); no save-gate enforcement in UI |
| SearchPage | Functional | Placeholder copy still references "JAMIS ID" (OBE — JAMIS retired) |
| ArchivedPage | Scaffold | Negate action not wired |
| SystemInfoPage | Scaffold | Approval matrix data display; delegation config not yet built |

---

## Immediate Unblocked Work

### 1. GUI page rework (active priority)

Rework each page for production-quality UI/UX. Starting point: pages run and render, but need:

- Consistent layout spacing and visual hierarchy
- CA Section tab on `AraDetailPage` (currently missing — only PM + Controller tabs exist)
- Save-before-action gate enforcement in the PM and CA tabs
- Negate action wired on `ArchivedPage`
- Delegation config on `SystemInfoPage`
- Remove stale "JAMIS ID" copy from `SearchPage` placeholder

### 2. Unit tests for all Phase 2 services

`ARA.Application.Tests` has 1 placeholder. Every service needs a test class:
`AraServiceTests`, `AraPmSectionServiceTests`, `AraControllerSectionServiceTests`, `ClinEntryServiceTests`, `DocumentServiceTests`, `ApprovalRecordServiceTests`, `CategoryServiceTests`, `JobTitleServiceTests`, `UserServiceTests`

Convention: `MethodName_StateUnderTest_ExpectedBehavior`. Mock only at the repository layer.

### 3. Azure Blob Storage integration for document uploads

Documents are stored as metadata only. The `DocumentsTab` UI exists but no actual file upload
pipeline is wired. Need either a SAS token endpoint or a streaming proxy on the API. Backend
`DocumentService` and `DocumentRepository` exist; the storage layer does not.

### 4. Document requirement tracking

`AraAttachmentRequirementLink` table exists in the DB but no service/repository/API manages
which document requirements must be satisfied per stage and category, or which PDFs satisfy them.
This enforces the CA submit gate for Non-Early Start ARAs.

---

## Backend Feature Gaps

### ARA Reference number generation

`Reference` field is never populated. `usp_AraCreate` does not generate it. Numbering scheme
needs to be confirmed with the product owner.

### Approval & Threshold Matrix routing

`AraService.ApproveAsync` transitions directly to `Approved` (single-approver simplification).
Full sequential matrix-driven routing is defined in `CLAUDE.md` and can now be built — all 12
ambiguities are resolved.

### Delegation configuration

`DelegationService` and `DelegationsController` exist. The `SystemInfoPage` displays delegation
information, but full delegation management UI (create/edit/delete) is not built.

### Session timeout enforcement

User guide requires exactly 3 hours of inactivity. Not enforced in API or frontend.

---

## Infrastructure / Deployment

### Okta (production auth)

Dev mode uses `DevAuthenticationHandler` (bypasses Okta entirely). To enable real Okta:

- Backend: populate `appsettings.Development.json` with real Okta values (already templated)
- Frontend: `src/lib/okta-config.ts` is wired; just needs the right env pointing at real Okta
- Okta test credentials are in `CLAUDE.md` → Okta Configuration

### On-prem deployment

Runbooks and installation scripts exist in `docs/` and `scripts/`. See `docs/ARA_DEPLOYMENT_CHECKLIST.md`.

### CORS

`AllowedOrigins` in `appsettings.json` needs the production frontend URL.

---

## OBE — Do Not Build

- **JAMIS export / OMS lookups** — JAMIS and OMS are retired. All references in legacy code are OBE.
  Org, Contract Number, and CLIN are free-text per legacy behavior.
- **Costpoint integration** — Not a current requirement. Fields remain free-text.
- **Azure Container Apps** — Deployment has pivoted to on-prem. Do not build Azure-specific infra.

---

## Recommended Order of Attack

1. **GUI page rework** — Active priority. Start with AraDetailPage CA tab and save-gate enforcement.
2. **Unit tests** — Cover all Phase 2 service methods before codebase grows further.
3. **Azure Blob Storage + document requirement tracking** — Unblocks the CA submit gate.
4. **Approval matrix routing** — All ambiguities resolved; can now implement full sequential chain.
5. **Reference number generation** — Confirm numbering scheme with product owner then implement.
6. **Delegation management UI** — Backend exists; frontend config UI needed.
7. **Okta production wiring** — When ready to move off dev mode.
