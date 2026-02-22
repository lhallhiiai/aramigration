# ARA Frontend Implementation Plan

## Context

Phase 2 (backend API) is complete. The frontend is a bare scaffold — Vite + React 19 + TypeScript strict + Tailwind v4 + shadcn/ui v3 configured but with zero components, no routing, no API integration, and no state management. The goal is to build a working, navigable frontend that connects to the running backend at `http://localhost:5081` and supports the full ARA workflow (create, view, edit, submit, approve, reject, cancel, negate) while deferring features blocked on stakeholder feedback (approval matrix routing, $50K questions, JAMIS/OMS autocomplete, blob storage upload).

**Critical constraint:** `erasableSyntaxOnly: true` in tsconfig — TypeScript `enum` keyword is forbidden. All enums must be `const` objects with `as const` + derived types.

---

## Step 0: Install Dependencies + shadcn Components

**npm packages to add:**
```
react-router-dom @tanstack/react-query zustand
react-hook-form @hookform/resolvers zod date-fns
```

**shadcn/ui components to generate** (via `npx shadcn@latest add`):
```
button card input label select textarea table tabs badge
dialog alert-dialog dropdown-menu separator sonner
form skeleton sheet sidebar scroll-area tooltip avatar popover
```

**Modify:** `vite.config.ts` — add dev proxy:
```ts
server: {
  proxy: {
    "/api": { target: "http://localhost:5081", changeOrigin: true }
  }
}
```

**Modify:** `index.html` — update `<title>` to "ARA - At Risk Authorization"

**Verify:** `npm run build` passes.

---

## Step 1: Types + API Client

Create the TypeScript type system mirroring all backend DTOs/enums, plus a central fetch wrapper.

### Files to create

| File | Purpose |
|------|---------|
| `src/types/enums.ts` | Const objects for AraStatus, UserRole, RiskCategory, ApprovalActionType, AraType, AraTab |
| `src/types/ara.ts` | AraListItem, AraDetail, CreateAraRequest, UpdateAraRequest |
| `src/types/sections.ts` | AraPmSection, SavePmSectionRequest, AraControllerSection, SaveControllerSectionRequest |
| `src/types/clin.ts` | ClinEntry, CreateClinRequest, UpdateClinRequest |
| `src/types/document.ts` | AraDocument, CreateDocumentRequest |
| `src/types/approval.ts` | ApprovalRecord, RejectRequest |
| `src/types/user.ts` | User |
| `src/types/category.ts` | Category |
| `src/types/jobTitle.ts` | JobTitle |
| `src/types/index.ts` | Barrel re-exports |
| `src/lib/api-client.ts` | `apiClient.get/post/put/delete` wrapping fetch, ApiError class |

**Enum pattern** (since `erasableSyntaxOnly: true`):
```ts
export const AraStatus = {
  Draft: 1,
  PendingContractAdministrator: 2,
  PendingController: 3,
  PendingApproval: 4,
  Approved: 5,
  Exported: 6,
  Expired: 7,
  Negated: 8,
  Cancelled: 9,
} as const;
export type AraStatus = (typeof AraStatus)[keyof typeof AraStatus];
```

**Verify:** `npm run build` passes.

---

## Step 2: Service Layer

One service file per backend controller — plain async functions using `apiClient`. No hooks here per CLAUDE.md.

| File | Functions |
|------|-----------|
| `src/services/araService.ts` | fetchAllActive, fetchPending, fetchArchived, fetchExpirations, fetchByStatus, search, fetchDetail, create, update, submitByPm, submitByCa, submitByController, approve, reject, cancel, negate |
| `src/services/sectionService.ts` | fetchPmSection, savePmSection, fetchControllerSection, saveControllerSection |
| `src/services/clinService.ts` | fetchClins, createClin, updateClin, deleteClin |
| `src/services/documentService.ts` | fetchDocuments, createDocument, deleteDocument |
| `src/services/approvalService.ts` | fetchApprovals |
| `src/services/userService.ts` | fetchCurrentUser, fetchAllUsers, fetchUsersByRole |
| `src/services/categoryService.ts` | fetchCategories |
| `src/services/jobTitleService.ts` | fetchJobTitles |

**Verify:** `npm run build` passes.

---

## Step 3: Hooks + Store

TanStack Query hooks wrapping every service function, a Zustand store for UI state, and an auth hook.

| File | Contents |
|------|----------|
| `src/lib/query-client.ts` | QueryClient with 30s staleTime, 1 retry |
| `src/hooks/useAras.ts` | useActiveAras, usePendingAras, useArchivedAras, useExpirationAras, useArasByStatus, useAraSearch, useAraDetail, useCreateAra, useUpdateAra + all workflow mutation hooks |
| `src/hooks/useSections.ts` | usePmSection, useControllerSection, useSavePmSection, useSaveControllerSection |
| `src/hooks/useClins.ts` | useClins, useCreateClin, useUpdateClin, useDeleteClin |
| `src/hooks/useDocuments.ts` | useDocuments, useCreateDocument, useDeleteDocument |
| `src/hooks/useApprovals.ts` | useApprovals(araId, revision?) |
| `src/hooks/useUsers.ts` | useCurrentUser, useAllUsers, useUsersByRole |
| `src/hooks/useCategories.ts` | useCategories (staleTime: Infinity) |
| `src/hooks/useJobTitles.ts` | useJobTitles (staleTime: Infinity) |
| `src/hooks/useAuth.ts` | useAuth — wraps useCurrentUser, exposes role booleans |
| `src/store/uiStore.ts` | sidebarOpen, quickSearchTerm |

All mutations invalidate relevant query keys on success.

**Verify:** `npm run build` passes.

---

## Step 4: App Shell + Layout + Routing

Establish the application shell with sidebar navigation, top bar with quick search, and route definitions.

### Files to modify
- `src/main.tsx` — wrap with QueryClientProvider + BrowserRouter
- `src/App.tsx` — Routes + AppLayout

### Files to create

| File | Purpose |
|------|---------|
| `src/components/layout/AppLayout.tsx` | Sidebar + TopBar + `<Outlet />` content area |
| `src/components/layout/AppSidebar.tsx` | Nav links: Action List, Dashboard, Create ARA (Creator only), Search, Archived, System Info |
| `src/components/layout/TopBar.tsx` | App title, QuickSearch input, current user name + role badge |
| `src/components/layout/QuickSearch.tsx` | Search input → navigates to `/search?q=...` |
| `src/lib/format.ts` | formatCurrency, formatDate, formatDateTime helpers |
| `src/lib/ara-helpers.ts` | getStatusLabel, getRiskCategoryLabel, isTerminalStatus maps |
| `src/lib/constants.ts` | APP_TITLE, SEARCH_DEBOUNCE_MS, CURRENCY_LOCALE |

### Page stubs (all in `src/pages/`)
ActionListPage, DashboardPage, CreateAraPage, SearchPage, AraDetailPage, ArchivedPage, SystemInfoPage, NotFoundPage — each renders a heading placeholder.

### Routes
| Path | Page | Notes |
|------|------|-------|
| `/` | redirect → `/action-list` | |
| `/action-list` | ActionListPage | |
| `/dashboard` | DashboardPage | |
| `/create` | CreateAraPage | Creator role only |
| `/search` | SearchPage | |
| `/aras/:araId` | AraDetailPage | |
| `/archived` | ArchivedPage | |
| `/system-info` | SystemInfoPage | |
| `*` | NotFoundPage | |

**Verify:** App renders in browser with working sidebar navigation. All routes resolve. `npm run build` passes.

---

## Step 5: List Pages

Implement the four list/table pages with real API data.

### Shared components (`src/components/Ara/`)

| Component | Purpose |
|-----------|---------|
| `AraTable.tsx` | Reusable table: Reference, Title, Category, Status, Amount, Expiration, Created |
| `AraStatusBadge.tsx` | Colored badge per AraStatus |
| `AraRiskCategoryLabel.tsx` | Human-readable category name |

### Shared components (`src/components/shared/`)

| Component | Purpose |
|-----------|---------|
| `LoadingState.tsx` | Skeleton loading layout |
| `ErrorState.tsx` | Error display with retry button |
| `EmptyState.tsx` | Icon + message for empty collections |

### Page implementations

| Page | Data hook | Key behavior |
|------|-----------|-------------|
| ActionListPage | usePendingAras + useActiveAras | Two tabs: "My Action List" / "See All ARAs". Rows click → `/aras/{id}` |
| DashboardPage | useExpirationAras + useArasByStatus | Two sections: expirations (highlight <30 days) + pending by status |
| SearchPage | useAraSearch | Debounced search input, pre-populated from `?q=` query param |
| ArchivedPage | useArchivedAras | Table with Negate action column (CA only, Exported status only) |

**Verify:** All four pages display real data. Row clicks navigate to detail. Quick search works end-to-end. `npm run build` passes.

---

## Step 6: ARA Detail Page

The most complex page — tabbed view with role-based editability, workflow actions, CLINs, documents, and approval history.

### Components (`src/components/Ara/`)

| Component | Purpose |
|-----------|---------|
| `AraDetailHeader.tsx` | Reference, Status badge, Revision, Category, Amount, dates — always visible above tabs |
| `AraDetailTabs.tsx` | Tab container: Summary, PM Section, Controller Section, Documents, Approval Cycle |
| `AraSummaryTab.tsx` | All AraDetail fields in card layout. Editable when user=PM & status=Draft |
| `PmSectionTab.tsx` | PM narrative textareas. Editable when user=PM & status=Draft |
| `ControllerSectionTab.tsx` | Controller fields + embedded ClinWorksheet. Editable when user=Controller & status=PendingController |
| `ClinWorksheet.tsx` | CLIN table with add/edit/delete + totals footer. Hidden for Early Start |
| `DocumentsTab.tsx` | Document list + metadata registration form (file upload deferred) |
| `ApprovalCycleTab.tsx` | Read-only timeline/table of approval records grouped by revision |
| `WorkflowActionBar.tsx` | Sticky action bar with role/status-conditional buttons (Save, Submit, Approve, Reject, Cancel, Negate) |
| `RejectDialog.tsx` | Dialog: comment (required), reason code, rejection areas → calls reject mutation |

### Editability rules

| User is | ARA Status | Editable sections |
|---------|-----------|------------------|
| PM | Draft | Summary + PM Section |
| CA | PendingContractAdministrator | (no form fields yet — deferred $50K questions) |
| Controller | PendingController | Controller Section + CLINs |
| Approver | PendingApproval | None (read-only + approve/reject) |
| Anyone | Terminal statuses | All read-only |

### Workflow button visibility

| Button | Shown when |
|--------|-----------|
| Save | Section is editable for current user |
| Sign & Submit (PM) | User=PM, Status=Draft |
| Submit (CA) | User=CA, Status=PendingCA |
| Submit (Controller) | User=Controller, Status=PendingController |
| Approve | User=Approver, Status=PendingApproval |
| Reject | User=CA/Controller/Approver at their stage |
| Cancel | User=PM, non-terminal status |
| Negate | User=CA, Status=Exported |

**Verify:** Navigate to `/aras/{id}`, all tabs render, workflow buttons match role/status, save/submit/approve/reject work. `npm run build` passes.

---

## Step 7: Create ARA Page

Multi-step form using react-hook-form + zod validation.

### Components (`src/components/CreateAra/`)

| Component | Purpose |
|-----------|---------|
| `StepIndicator.tsx` | Horizontal stepper (steps 1-4) |
| `Step1RiskCategory.tsx` | Category selection from useCategories. Pre-Contract Costs → isEarlyStart=true |
| `Step2ContractInfo.tsx` | Conditional fields: Non-Early Start (Contract Number, Division, etc.) vs Early Start (OMS Number, Title, Customer). Common: amounts, dates, company |
| `Step3RoleAssignment.tsx` | CA/Controller/PM dropdowns from useUsersByRole |
| `Step4Summary.tsx` | Read-only review + "Create ARA" button |
| `FormNavigation.tsx` | Back/Next with per-step validation |

### Validation
`src/lib/validation/createAraSchema.ts` — Zod schema matching backend's CreateAraRequestValidator. Conditional: OMS required when Early Start, Contract required when Non-Early Start.

### Role guard
Only Creator role can access. Others see access-denied message.

**Verify:** Creator can complete all steps and create an ARA. New ARA appears in lists. Validation prevents bad submissions. `npm run build` passes.

---

## Step 8: Polish

| Item | File(s) |
|------|---------|
| Toast notifications | Add Sonner `<Toaster />` in App.tsx. Add toast calls to all mutation onSuccess/onError in hooks |
| Error boundary | `src/components/ErrorBoundary.tsx` wrapping routes |
| Loading/error/empty states | Ensure every data-fetching page handles isLoading, isError, empty array |
| Role-based route guard | Wrap `/create` route — show access-denied for non-Creator |

**Verify:** Full end-to-end: create ARA → view in list → open detail → save section → submit through stages → approve. Toast notifications appear. Error states display. `npm run build` passes.

---

## File Count Summary

- **Types:** 10 files
- **Services:** 8 files
- **Hooks:** 9 files
- **Store:** 1 file
- **Lib:** 7 files (including existing utils.ts)
- **Layout components:** 4 files
- **ARA components:** 13 files
- **CreateAra components:** 6 files
- **Shared components:** 3 files
- **Pages:** 8 files
- **Other:** 1 file (ErrorBoundary)
- **Modified:** 4 files (main.tsx, App.tsx, vite.config.ts, index.html)
- **shadcn generated:** ~20 files in components/ui/

**Total:** ~70 hand-written files + ~20 generated

---

## Deferred (waiting on stakeholder feedback)

- Approval & Threshold Matrix routing (ambiguity #1, #7) — single-approver for now
- ARA form questions appearing >$50K (ambiguity #2)
- JAMIS/OMS autocomplete (no external APIs) — plain text inputs for now
- Azure Blob Storage file upload — metadata-only registration for now
- Email notifications (backend-only concern)

---

## Verification

After all steps complete:
1. `npm run build` passes with zero errors
2. `npm run dev` starts and the app loads at `http://localhost:5173`
3. Backend running at `http://localhost:5081` — Vite proxy forwards `/api/*`
4. Can navigate all pages via sidebar
5. Can create an ARA through the multi-step form
6. Can view ARA lists (action list, dashboard, search, archived)
7. Can view ARA detail with all tabs
8. Can perform workflow transitions (submit, approve, reject, cancel)
9. Can manage CLIN entries on the controller section
10. Can view approval history

---

## Frontend Build Complete

All 8 steps have been implemented. The frontend is fully built and ready to run locally against the backend API.

### Prerequisites

- **Node.js 24** (installed via Homebrew)
- **.NET SDK 10.0.103** (installed via Homebrew at `/opt/homebrew/opt/dotnet`)
- **Azure SQL Database** deployed and seeded (see `scripts/` for provisioning)
- **Azure CLI** authenticated (`az login`) for database access

### Running Locally

You need two terminal sessions — one for the backend API and one for the frontend dev server.

#### Terminal 1 — Backend API

```bash
# Set up .NET PATH (required each shell session)
export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
export PATH="$DOTNET_ROOT:$PATH"

# Start the API server
dotnet run --project new/backend/src/ARA.Api
```

The API starts at `http://localhost:5081`. Verify with:

```bash
curl http://localhost:5081/health
# Expected: 200 Healthy
```

#### Terminal 2 — Frontend Dev Server

```bash
# Install dependencies (first time only)
cd new/frontend
npm install

# Start the Vite dev server
npm run dev
```

The app opens at `http://localhost:5173`. The Vite dev proxy forwards all `/api/*` requests to the backend at `http://localhost:5081`.

### Build Commands

**Frontend (run from `new/frontend/`):**

- `npm install` — Install all dependencies (first time or after package.json changes)
- `npm run dev` — Start Vite dev server with hot reload at `http://localhost:5173`
- `npm run build` — TypeScript compile + production Vite build to `dist/`
- `npm run lint` — Run ESLint across all source files
- `npm run preview` — Serve the production build locally for testing

**Backend (run from repo root):**

- `dotnet build new/backend/ARA.slnx` — Build the full backend solution
- `dotnet test new/backend/ARA.slnx` — Run all backend unit tests
- `dotnet run --project new/backend/src/ARA.Api` — Start the backend API server

### Tech Stack Summary

| Layer           | Technology                                            |
| --------------- | ----------------------------------------------------- |
| Framework       | React 19 + TypeScript (strict, `erasableSyntaxOnly`)  |
| Build tool      | Vite 7                                                |
| Styling         | Tailwind CSS v4 (`@tailwindcss/vite` plugin)          |
| UI components   | shadcn/ui v3 (New York style)                         |
| Server state    | TanStack Query v5                                     |
| Client state    | Zustand v5                                            |
| Routing         | React Router DOM v7                                   |
| Forms           | react-hook-form v7 + Zod v4                           |
| Toasts          | Sonner v2                                             |
| Date formatting | date-fns v4                                           |
| Icons           | Lucide React                                          |

### Dev Authentication

When `ASPNETCORE_ENVIRONMENT=Development` and `AzureAd:TenantId` is empty in `appsettings.json`, the backend activates `DevAuthenticationHandler`. This bypasses Entra ID and sets:

- **User ID:** `dev-user-00000000`
- **Email:** `dev@local.dev`

The frontend's `useAuth` hook resolves the current user from this claim via the `/api/users/me` endpoint. Make sure a matching user record exists in the database seed data.

### Known Lint Notes

There are 6 ESLint warnings in shadcn/ui generated files (`src/components/ui/`). These are upstream issues in the shadcn templates and do not affect application code. All hand-written source files pass lint cleanly.
