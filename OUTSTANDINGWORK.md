# ARA Migration — Outstanding Work

Generated: 2026-02-21

## Current State

- **Phase 1**: COMPLETE — Foundation (toolchain, scaffold, DB, infrastructure, domain)
- **Phase 2**: COMPLETE — ARA Workflow API backend (Application + Infrastructure + API layers)

---

## Immediate (unblocked right now)

### 1. Deploy new stored procedures to Azure SQL

The 5 SPs added to `scripts/sql/003_stored_procedures.sql` have not been deployed to the live database:

- `usp_AraUpdateStatus`
- `usp_AraPmSectionGetByAraId`
- `usp_AraPmSectionUpsert`
- `usp_AraControllerSectionGetByAraId`
- `usp_AraControllerSectionUpsert`

Re-run `scripts/Invoke-AraMigration.ps1` against the deployed Azure SQL instance to apply them.

### 2. Smoke test the API end-to-end

With the API running locally against Azure SQL, verify `GET /api/categories` returns seed data.
This confirms the full stack: auth bypass → controller → service → repository → SQL → response.

### 3. Unit tests for all Phase 2 services

The test project (`ARA.Application.Tests`) has 1 placeholder test. Every service method needs
an xUnit test class per CLAUDE.md conventions:

- `AraServiceTests`
- `AraPmSectionServiceTests`
- `AraControllerSectionServiceTests`
- `ClinEntryServiceTests`
- `DocumentServiceTests`
- `ApprovalRecordServiceTests`
- `CategoryServiceTests`, `JobTitleServiceTests`, `UserServiceTests`

Test naming convention: `MethodName_StateUnderTest_ExpectedBehavior`
Mock only at the repository layer (never mock services).

### 4. React frontend — entire application UI

The `new/frontend/` scaffold exists but has zero application code. Every module from the
user guide must be built:

| Module | Key screens / components |
|---|---|
| Landing / My Action List | Pending ARAs list, See All ARAs toggle |
| Dashboard | Expiration warnings sorted by date, ARAs grouped by status |
| Create ARA | Multi-step form: Step 1 (category/type), Step 2 (assignments/contract) |
| ARA Detail | PM tab, CA tab, Controller tab (with CLIN worksheet), Approvals tab |
| Document Upload | Upload PDF, tag to multiple document requirements |
| Search | Full search with filters |
| Quick Search | Partial or full ARA ID / JAMIS ID lookup from any page |
| Archived | Exported + Negated ARAs, Negate action for CA |
| ARA System Information | Approval Matrix display, Delegations configuration |

Frontend tech stack: React + TypeScript strict, Tailwind CSS v4, shadcn/ui v3, TanStack Query
for server state, Zustand for global client state.

---

## Blocked on Business / Product Decisions

These cannot be built until the product owner provides answers.
See CLAUDE.md → Ambiguities and Gaps for full context.

| # | Ambiguity | What it blocks |
|---|---|---|
| **#1** | Approval & Threshold Matrix thresholds undocumented | Real approval routing in `AraService.ApproveAsync` (currently simplified to single-approver direct-to-Approved) |
| **#2** | PM/CA questions never listed | Actual form fields on the PM and CA tabs; which questions appear above/below the $50K threshold |
| **#7** | Multi-approver chain is undefined | Whether approvers act sequentially or in parallel; what the terminal approval condition is |
| **#8** | Export to JAMIS process entirely absent | The export endpoint, what data is sent, and the `Exported` status transition |
| **#3** | Revision field behavior undefined | How Revision increments on rejection/resubmission cycles |
| **#4** | InterestImpact and ExpectedBurnRate undefined | Data type, source, and validation rules for the Controller section fields |
| **#5** | Early Start CA Submit availability inconsistency | Whether CA Submit is available before or only after document upload for Early Start ARAs |
| **#6** | Contract Manager vs Contract Administrator naming conflict | Whether these are the same role or two distinct roles |
| **#9** | Delegation configuration not described | What can be delegated, who can delegate, how delegation affects workflow routing |
| **#10** | OMS Number format not specified | Format constraints, minimum length, error handling for OMS lookup |
| **#11** | ARA expiration logic not described | How expiration dates are set and what triggers the `Expired` status transition |
| **#12** | Document upload limits absent | Maximum file size and maximum number of uploads per stage |

**Recommended priority for product owner:** Resolve #1, #2, #7, and #8 first — these unblock the
most code.

---

## Backend Feature Gaps (not yet built)

### Email notifications

All 6 trigger points are currently no-ops. Needs an `IEmailService` interface in the Application
layer and a provider implementation (e.g. Azure Communication Services or SendGrid) in Infrastructure.

Required triggers (per CLAUDE.md business rules):

- PM signs and submits
- CA submits for next approval
- Controller submits for approval
- Any approver approves (email to prior actors + next approver)
- Any rejection (email to all prior actors)
- ARA is negated (email to all creation and approval parties)

### ARA Reference number generation

The `Reference` field (e.g. "00001234") is never populated. `usp_AraCreate` does not generate it.
The numbering scheme needs to be confirmed and a generation mechanism added.

### Export to JAMIS

`POST /api/aras/{id}/export` does not exist. Blocked on ambiguity #8.

### JAMIS / OMS live lookups (autocomplete validation)

Per CLAUDE.md business rules, these fields must validate against live external data:

- Org (Sector, Group, Operation, Division, Description) — validated against JAMIS
- Contract Number — validated against JAMIS
- CLIN pre-population — pulled from JAMIS for the entered contract
- OMS Number — validated against OMS

None of these integrations have been built. They require access to the JAMIS and OMS APIs.

### Approval & Threshold Matrix routing

`AraService.ApproveAsync` currently transitions directly to `Approved` (single-approver
simplification). Full matrix-driven sequential routing requires resolving ambiguities #1 and #7.

### Delegation configuration

The ARA System Information page includes a Delegations section. No domain model, repository,
service, or API exists for it. Blocked on ambiguity #9.

### Session timeout enforcement

The user guide requires exactly 3 hours of inactivity timeout. Not currently enforced by the API
or frontend.

### Document requirement tracking

The `AraAttachmentRequirementLink` table exists in the database but no service, repository, or API
manages which document requirements exist per stage, or which uploaded PDFs satisfy them.
Required for the "must upload before submit" gate at the CA stage (Non-Early Start only).

### Azure Blob Storage integration

Documents are stored as metadata only. The frontend needs a mechanism to upload PDF files.
Options: pre-signed URL endpoint (SAS token), or a streaming upload proxy endpoint on the API.
Neither exists yet.

---

## Infrastructure / Deployment

### Entra ID configuration (production auth)

`appsettings.Development.json` needs real values to switch from dev bypass to real Entra ID:

```json
"AzureAd": {
  "TenantId": "<tenant-id>",
  "ClientId": "<client-id>",
  "Domain": "<domain>"
}
```

No code change required — filling in `TenantId` automatically disables the dev bypass.

### Azure Container Apps deployment

No Dockerfile, CI/CD pipeline, or Container Apps configuration exists yet. Needed for:

- Docker image build for `ARA.Api`
- Docker image build / static hosting for `new/frontend/`
- Azure Container Apps environment and app configuration
- Managed identity or connection string wiring for Azure SQL in production
- Azure Blob Storage account and container for document uploads

### CORS configuration for production

`AllowedOrigins` in `appsettings.json` needs the production frontend URL populated.

---

## Recommended Order of Attack

1. **Product owner session** — Resolve ambiguities #1, #2, #7, #8 (approval matrix, PM
   questions, multi-approver chain, JAMIS export). These unblock the most downstream work.

2. **Deploy new SPs + smoke test** — Run migration script, verify full stack end-to-end.

3. **Unit tests** — Cover all Phase 2 service methods before the codebase grows further.

4. **Email service** — Can be built independently of product decisions; just needs a provider.

5. **React frontend** — Largest single effort. Start with landing page and ARA list views while
   waiting on product owner answers for form field details.

6. **Document requirement tracking + Blob Storage integration** — Enables the document upload
   gate at the CA stage.

7. **JAMIS / OMS integration** — Depends on API access being available.

8. **Export to JAMIS + Reference number** — Once ambiguity #8 is resolved.

9. **Approval matrix routing** — Once ambiguities #1 and #7 are resolved.

10. **Production deployment** — Entra ID config, Container Apps, CI/CD, Blob Storage.
