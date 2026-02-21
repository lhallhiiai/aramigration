# Project: ARA ColdFusion Migration

## Application Overview

This project is dealing with removing cold fusion from our stack, and replacing it with a new modern technological stack

## Authoritative Reference Document

- The user guide for this application is located at:
  `legacy/ARAUserGuideV2.md`
- This document is the single source of truth for intended
  application behavior.
- Before making any assumption about how a feature should work,
  read the relevant section of `legacy/ARAUserGuideV2.md` first.
- If implemented behavior conflicts with the user guide,
  the user guide wins. Stop, flag the conflict, and ask before
  proceeding.
- If the user guide does not cover a scenario, say so explicitly
  rather than assuming. Use this exact phrase:
  "This scenario is not covered in the user guide. Based on
  the ColdFusion code it appears to [behavior]. Please confirm
  before I proceed."
- When starting any conversion task, state which section of
  the user guide applies and summarize the intended behavior
  before writing any code.

## Target Stack

- Backend: .NET 8 ASP.NET Core Web API
- Frontend: React + TypeScript + Tailwind CSS + shadcn/ui
- Database: Azure SQL Database
- Hosting: Azure Container Apps
- Auth: Microsoft Entra ID

## Azure Configuration

- Subscription: Azure subscription 1
- Region: West US 2
- Naming convention: hii-ara-dev-[resource]
- Resource Group: ARA-Dev-Work

## Coding Conventions

## Non-Negotiable Rules

These apply to every file generated. Never deviate from these without
explicit instruction:

- All code is C# (.NET 10) on the backend, TypeScript (strict mode)
  on the frontend. Never use JavaScript files in the frontend.
- Never use `var` in C#. Always use explicit types or `readonly`.
- Never use `any` in TypeScript. Always type everything explicitly.
- Never generate code with TODO comments. If something is incomplete,
  say so in your response, not in the code.
- Never use inline styles in React components. Tailwind classes only.
- All public methods and classes must have XML doc comments in C#.
- All functions over 20 lines should be flagged and a refactor suggested.
- All scripts that are created my only be powershell
- Never update or add any files in the folder named old or any of its subdirectories

## Architecture Patterns

### Backend

- Pattern: Clean Architecture with the following layer order:
  API (Controllers) → Application (Services) → Domain → Infrastructure (Repos)
- Controllers are thin. No business logic in controllers — ever.
- Use the Repository pattern. Every repository has an interface in the
  Domain layer and an implementation in the Infrastructure layer.
- Data access: Dapper only. No Entity Framework. Raw SQL with
  strongly-typed parameters.
- Never use string interpolation in SQL queries. Always parameterized.
- Return types: Use a Result\<T\> pattern for all service methods.
  Never throw exceptions for business rule failures.
- Example Result usage:

  ```csharp
  // Correct
  return Result<UserDto>.Failure("User not found");
  // Incorrect
  throw new NotFoundException("User not found");
  ```

- Never use inline SQL always use stored procedures and create one if necessary

### Frontend

- Component pattern: One component per file. Filename matches
  component name exactly (PascalCase).
- All components are functional. No class components.
- Props interfaces are defined in the same file as the component,
  named [ComponentName]Props.
- Example:

  ```typescript
  // Correct
  interface UserCardProps { userId: string; displayName: string; }
  export function UserCard({ userId, displayName }: UserCardProps) {}
  // Incorrect
  export function UserCard(props: any) {}
  ```

- State management: TanStack Query for all server state.
  Zustand for global client state. useState for local UI state only.
- Never fetch data directly in a component. Always use a custom
  hook named use[Resource] (e.g., useUsers, useOrderDetail).

## File & Folder Structure

### Backend Structure

```text
/src
  /Api
    /Controllers
    /Middleware
  /Application
    /[Feature]
      [Feature]Service.cs
      I[Feature]Service.cs
      [Feature]Dto.cs
  /Domain
    /Entities
    /Repositories (interfaces only)
  /Infrastructure
    /Repositories (implementations)
    /Database
```

### Frontend Structure

```text
/src
  /components
    /ui          ← shadcn/ui base components, never modified directly
    /[Feature]   ← feature-specific components
  /hooks         ← all custom hooks
  /pages         ← page-level components and routing
  /services      ← API call functions (not hooks, just fetch wrappers)
  /types         ← shared TypeScript interfaces and types
  /store         ← Zustand stores
```

## Naming Conventions

- C# classes: PascalCase
- C# private fields: _camelCase with underscore prefix
- C# interfaces: IPascalCase
- TypeScript interfaces: PascalCase (no I prefix)
- TypeScript enums: PascalCase with PascalCase members
- React components: PascalCase
- React hooks: camelCase prefixed with "use"
- API endpoints: kebab-case nouns, plural (/api/users, /api/order-items)
- Database tables: PascalCase singular (User, OrderItem)
- Database columns: PascalCase (UserId, CreatedAt)
- Azure resources: [company]-[app]-[env]-[resource-type]
  e.g. acme-crm-prod-api

## Testing Conventions

- Framework: xUnit (backend), Vitest + React Testing Library (frontend)
- Every service method gets a test class named [Service]Tests
- Test method naming: MethodName_StateUnderTest_ExpectedBehavior
  e.g. GetUser_WithInvalidId_ReturnsFailureResult
- Always test: happy path, null/empty inputs, boundary conditions,
  and business rule violations
- No magic numbers or strings in tests. Use named constants.
- Mock only at the repository layer. Never mock services in
  service-to-service tests.

## Error Handling

- Backend: Global exception middleware handles all unhandled exceptions.
  Never catch and swallow exceptions silently.
- All caught exceptions must be logged with ILogger before handling.
- API error responses always follow RFC 7807 Problem Details format.
- Frontend: Every TanStack Query call must handle isError state visibly.
  Never silently fail a data fetch.

## What to Always Include Without Being Asked

- Input validation on every API endpoint using FluentValidation
- Cancellation token parameters on all async methods
- ILogger injection in every service and controller
- XML doc comments on all public members (backend)
- Loading and error UI states on every data-fetching component (frontend)
- Null checks at all public API boundaries

## What to Never Include Without Being Asked

- Logging frameworks other than Microsoft.Extensions.Logging
- Any npm package not already in package.json
- Docker configuration changes
- Database schema changes
- New Azure resources
- Authentication/authorization changes

### Key Business Domain Terms

[List any domain-specific terms so Claude understands
your business context without re-explaining every session]

## Git & Source Control Directives

### Git Non-Negotiable Rules

- Never commit directly to `main` or `develop`. Always work on a feature branch.
- Never commit secrets, connection strings, API keys, or passwords. Ever.
- Never force push to any shared branch.
- Never commit commented-out code. Delete it — git history preserves it if needed.
- Never commit files that belong in .gitignore (build artifacts, node_modules,
  bin/, obj/, .env files).
- Always confirm with me before running any destructive git command
  (reset --hard, rebase, branch deletion).
- Never commit auto-generated files unless explicitly told to.

### Branch Naming Convention

Pattern: [type]/[short-description]

Use kebab-case for the description. Keep it under 50 characters.

Types and when to use them:

- feature/   → new functionality being converted from ColdFusion
- fix/        → bug fix in already-converted code
- data/       → database migration scripts or schema changes
- infra/      → Azure infrastructure or Bicep template changes
- refactor/   → code restructuring with no behavior change
- test/       → adding or fixing tests only
- docs/       → documentation updates including CLAUDE.md changes
- chore/      → dependency updates, config changes, tooling

Examples:

```text
feature/user-authentication
feature/order-management-api
data/add-customer-indexes
infra/container-apps-setup
fix/order-total-calculation
```

### Commit Message Format

Follow Conventional Commits specification exactly.

Structure:

```text
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

Rules:

- First line must be 72 characters or less
- Description is lowercase, no period at the end
- Use imperative mood ("add" not "added", "fix" not "fixed")
- Body explains WHAT changed and WHY, not HOW
- Always reference what ColdFusion file or feature this replaces
  in the body when applicable

Types:

```text
feat:     new feature or converted ColdFusion functionality
fix:      bug fix
data:     database migration or schema change
infra:    Azure infrastructure change
refactor: code change that neither fixes a bug nor adds a feature
test:     adding or updating tests
docs:     documentation changes
chore:    maintenance tasks, dependency updates
style:    formatting only, no logic change
```

Scope examples (use the feature area):

`auth, users, orders, products, reporting, api, frontend, db, azure, config`

Use `config` for changes to CLAUDE.md, project configuration files, or tooling settings.

Examples:

```text
feat(orders): add order summary endpoint

Converts OrderSummary.cfm to OrdersController and OrderService.
Implements GET /api/orders/{id}/summary returning OrderSummaryDto.

Replaces: /legacy/OrderSummary.cfm

---

data(users): add missing indexes to user search queries

Adds composite index on (LastName, FirstName) and single index
on Email column based on query patterns found in UserSearch.cfm.

Migration: 004_add_user_search_indexes.sql

---

fix(auth): correct token expiry calculation

Token was expiring immediately due to UTC/local time mismatch.
ColdFusion original had same bug — this is not a regression.
```

### When to Commit

- Commit after each logical unit of work is complete and tests pass
- Never commit broken code to any branch
- One concern per commit — do not bundle unrelated changes
- If a session produces multiple distinct changes, commit them separately
- Always run the test suite before committing:

```bash
dotnet test                    # backend
npm run test                   # frontend
npm run lint                   # frontend lint check
```

### Pull Request Rules

- Every feature branch requires a PR before merging to develop
- PR title follows the same format as commit messages
- PR description must include:
  - What ColdFusion functionality this replaces (if applicable)
  - What was tested and how
  - Any known limitations or follow-up items
  - Screenshots for any UI changes

PR description template to use:

```markdown
## What This Does
[Plain English description]

## ColdFusion Replacement
Replaces: [filename(s)]
Feature inventory item: [item name from FEATURE_INVENTORY.md]

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manually tested: [describe what you tested]

## Notes
[Anything else reviewers should know]
```

### .gitignore Requirements

Always ensure these are ignored and never committed:

```gitignore
# Secrets and environment
.env
.env.*
appsettings.Development.json
appsettings.Local.json

# Build output
bin/
obj/
dist/
build/
.next/

# Dependencies
node_modules/

# IDE and OS
.vs/
.vscode/settings.json
.DS_Store
Thumbs.db

# Azure and cloud
.azure/
terraform.tfstate
terraform.tfstate.backup
*.tfvars

# Logs
*.log
logs/
```

### Tagging & Releases

- Use semantic versioning: v[MAJOR].[MINOR].[PATCH]
- Tag only from main after a successful deployment
- MAJOR: breaking changes or major milestone completions
- MINOR: new feature module fully converted and deployed
- PATCH: bug fixes and small improvements
- Annotated tags only:
  `git tag -a v1.2.0 -m "Complete order management module conversion"`

### Migration-Specific Git Conventions

Since this is a migration project, always track what legacy code
each commit replaces:

- Keep a /legacy folder in the repo containing read-only copies
  of the original ColdFusion files for reference. Never modify
  these files — they are the source of truth for intended behavior.
- When a ColdFusion file is fully converted and tested, add a
  comment at the top of the legacy file:
  `<!--- MIGRATED: Replaced by [NewFile.cs] on [date] --->`
- Do not delete legacy files until the full cutover is complete
  and the new system is stable in production.

### Commands Claude Code Should Always Suggest (Never Run Automatically)

These commands must be confirmed by me before execution:

```bash
git reset
git rebase
git push --force or --force-with-lease
git branch -d or -D
git clean -fd
git stash drop
Any git command that modifies historyƒ
```

---

## User Guide Reference

> See **Authoritative Reference Document** above for the rules governing
> how to use `legacy/ARAUserGuideV2.md` during conversion tasks.
> The sections below document the application's domain, modules, business
> rules, terminology, and known gaps extracted from that guide.

---

### Application Purpose

The ARA (At Risk Authorization) application is a web-based workflow system
for submitting, routing, reviewing, and approving authorizations to spend
company funds on work before a contract modification or award is received.
It integrates with JAMIS (the accounting system) and OMS (the opportunity
tracking system) to validate inputs and export approved ARAs.

There are exactly two ARA types. Always enforce this distinction throughout
the system:

- **Authority to Spend Only**
- **Authority to Spend with Revenue Recognition**

---

### Major Functional Modules

| Module | Description |
| --- | --- |
| **Landing Page / My Action List** | Displays only ARAs awaiting the current user's action, or all active ARAs system-wide. |
| **Dashboard** | Displays ARA expirations sorted by expected expiration date and all pending ARAs grouped by status. |
| **Create ARA** | Multi-step form for submitting a new ARA; restricted to users with the Creator role only. |
| **Search ARA** | Full search interface for filtering and browsing all ARA records. |
| **Quick Search** | Partial or full ARA ID or JAMIS ID lookup, accessible from any page. |
| **ARA System Information** | Displays delegation configurations and the Approval & Threshold Matrix. |
| **CLIN Worksheet/Calculator** | Controller-only tool for allocating ARA funding across Contract Line Item Numbers; required for Non-Early Start only. |
| **Document Upload** | PDF upload interface available at the CA and Controller stages; supports many-to-one and one-to-many document tagging. |
| **Approval Cycle** | Read-only summary of all approver actions taken on an ARA; drives the final approval chain. |
| **Archived / Negate ARA** | CA-only capability to mark an Exported ARA as Negated when a contract modification is received post-export. |

---

### Roles

Always treat these as distinct system roles with non-overlapping
permissions unless the guide explicitly states otherwise:

- **Creator / Program Manager (PM)** – Creates ARAs, fills the PM
  section, signs and submits. Only the PM may cancel an ARA.
- **Contract Administrator (CA)** – Reviews the ARA after PM submission,
  answers questions, uploads documents, and submits forward or rejects.
- **Controller** – Reviews after CA; completes CLIN worksheet (Non-Early
  Start only), uploads documents, and submits for approval or rejects.
- **Approver** – One or more approvers in sequence, determined by the
  Approval & Threshold Matrix; can Review (read-only), Approve, or Reject.

---

### ARA Type Distinction: Non-Early Start vs. Early Start

Always branch logic on ARA type. The two paths differ in fields, required
documents, and Controller behavior.

**Non-Early Start risk categories** (use JAMIS Contract Number):

- Award Fees
- Mod Pending (Incremental Funding)
- Mod Pending (Exercise Option Period)
- Mod Pending (Not Exercise Option Period)
- Internal Cleared
- Commercial At-Risk
- Change in Scope
- Fixed Price Mod

**Early Start risk category** (use OMS Number instead of JAMIS):

- Pre-Contract Costs

| Behavior | Non-Early Start | Early Start |
| --- | --- | --- |
| Contract lookup field | JAMIS/Contract Number | OMS Number |
| Step 2 additional fields | Contract Manager, Controller | Title, Customer, Contract Administrator, Controller |
| CA documentation required | Yes | No |
| Controller CLIN worksheet | Required | Not required |
| Controller documentation required | Yes | No |

---

### Workflow Sequence (Sequential — Must Not Be Skipped)

Every ARA must traverse these stages in order:

1. **PM** creates, fills, saves, and signs & submits
2. **Contract Administrator** answers questions, saves, uploads docs
   (required for Non-Early Start), and submits for next approval
3. **Controller** completes CLIN worksheet (Non-Early Start only),
   saves, uploads docs, and submits for approval
4. **Approver(s)** review and approve or reject per the Approval &
   Threshold Matrix

---

### Business Rules — Always Enforce These

#### Session

- Must time out the session after exactly 3 hours of inactivity.

#### Role Enforcement

- Must restrict the Create ARA function to users with the Creator role.
  Never display it to other roles.
- Must restrict ARA cancellation to the PM only. No other role may cancel.
- Must restrict the Negate ARA action to the Contract Administrator only,
  and only from the Archived menu on Exported ARAs.

#### Save-Before-Action Gate

- Must require the PM to Save before Upload Documents or Sign & Submit
  are enabled. Never allow submission without a prior save.
- Must require the CA (Non-Early Start) to Save before the document
  upload option becomes available.

#### Section Lock-Down on Submission

- Must make each role's section of the ARA form read-only immediately
  after that role signs and submits. Never allow the submitting role to
  edit a submitted section.
- The only mechanism to unlock a submitted section is for the next user
  in the chain to reject the ARA.

#### Rejection Behavior

- A rejection at any stage (CA, Controller, or any Approver) must return
  the ARA to the PM's queue and restart the entire action chain from the
  beginning.
- Must send an email notification to every party who has taken action on
  the ARA at the time of rejection.
- Approver rejection must capture: a comment, a reason code, and the
  affected tab for resubmission focus.

#### Approval Routing

- Must route approved ARAs to the next approver automatically based on
  the Approval & Threshold Matrix. Never hard-code an approval chain.
- Must send an email to all prior actors when an Approver approves, and
  a separate email to the next approver.

#### $50K Question Threshold

- Must only display certain ARA questions when the ARA amount exceeds
  $50,000. Never show those questions for amounts at or below $50K.

#### CLIN Worksheet Rules (Non-Early Start Controller Only)

- Must pre-populate available CLINs from JAMIS for the entered contract.
- Must enforce that each pre-populated CLIN can only be used once per ARA.
- Must auto-calculate and display Total Cost, Total Fees, and Total when
  CLIN entries are complete. Never require manual entry of these totals.
- Must prevent submission if the combined Cost and Fee funding across all
  CLINs exceeds the total ARA Amount set by the PM.

#### Document Upload Rules

- Must accept PDF format only for all document uploads.
- Must allow one uploaded PDF to be tagged to satisfy multiple document
  requirements simultaneously.
- Must allow multiple PDFs to be uploaded to satisfy a single document
  requirement.
- Must not require documentation for Early Start ARAs at the CA or
  Controller stage. Always make it optional for Early Start.
- Must require documentation for Non-Early Start ARAs at the CA stage
  before the CA may submit forward.

#### Autocomplete Validation

- Must validate Org input against JAMIS (Sector, Group, Operation,
  Division, Description). Never allow free-text Org values.
- Must validate JAMIS/Contract Number against JAMIS live data.
- Must validate OMS Number against OMS live data.
- Always display a dropdown of matching values as the user types.

#### Negation

- Must only allow negation on ARAs in Exported status, accessed via the
  Archived menu.
- Must change status to "Negated" immediately on negation.
- Must send an email to all parties involved in the creation and approval
  of the ARA when negated.

#### Email Notifications

Always trigger email on these events:

- PM signs and submits
- CA submits for next approval
- Controller submits for approval
- Any approver approves (to prior actors and next approver)
- Any rejection (to all prior actors)
- ARA is negated (to all creation and approval parties)

#### ARA Statuses (Known from Guide)

- Expired – ARA reached end of period without a contract modification
- Negated – CA negated a previously exported ARA
- Archived – exported ARAs accessible via the Archived menu
- Revision tracking changes on rejection (see Ambiguities below)

---

### Domain Terminology Definitions

Always use these definitions. Never redefine them without confirming with
the business owner.

| Term | Definition |
| --- | --- |
| **ARA** | At Risk Authorization — a formal internal authorization to spend funds or recognize revenue before a contract modification or award is received. |
| **AJERAS** | Alion Journal Entry and Revenue Adjustment System — the parent application suite that hosts the ARA module. |
| **JAMIS** | The company's accounting/ERP system. ARA pulls Org, CLIN, and Contract Number data from JAMIS and exports approved ARAs back to it. |
| **OMS** | Opportunity Management System — tracks pre-contract opportunities; used as the contract reference for Early Start ARAs. |
| **Early Start** | An ARA for Pre-Contract Costs where the customer has authorized work in writing before a definitized contract exists. Uses OMS Number, not JAMIS. |
| **Non-Early Start** | Any ARA risk category other than Pre-Contract Costs; always tied to an existing JAMIS contract. |
| **CLIN** | Contract Line Item Number — the funding line within a JAMIS contract used to allocate ARA spending. |
| **Revenue Recognition** | The choice on an ARA to either authorize spending only, or authorize both spending and recognizing the associated revenue. |
| **Approval & Threshold Matrix** | A system-configured table that determines which approvers must act on an ARA and in what order, based on dollar thresholds and other criteria. |
| **Negation** | A CA action that marks an Exported ARA as Negated when a contract modification is subsequently received. Distinct from rejection and cancellation. |
| **Exported** | ARA status indicating the record has been exported to JAMIS. |
| **Expired** | ARA status indicating the authorization period lapsed without a contract modification being received. |
| **My Action List** | Landing page filter showing only ARAs currently awaiting the logged-in user's action. |
| **75% Letter / Limitation of Funds Notice** | A formal notice submitted to the customer when contract funding is nearly exhausted; a prerequisite for Modification Pending ARAs. |
| **Award Fees** | Fees estimated as a percentage of costs or revenue, not funded until formally awarded by the customer. |
| **T&M Contract** | Time and Materials contract — a contract type referenced in several risk category definitions. |
| **Modification Pending** | Risk category for ARAs where a contract funding increase, option period exercise, or period of performance extension is in process. |
| **Change in Scope** | Risk category for ARAs covering work outside the original statement of work on a cost reimbursement or T&M contract. |
| **Fixed Price Modification** | Risk category for ARAs on fixed price contracts requesting a funding or value increase. |
| **Commercial At-Risk** | Risk category for work performed for a commercial customer without an executed contract, based on prior commercial practice. |
| **Internally Cleared** | Risk category for ARAs where the risk condition was resolved after the report run date without customer involvement; must clear within 30 days or by end of subsequent quarter. |
| **Pre-Contract Costs** | The Early Start risk category; work authorized in writing by customer before contract definitization. |
| **Incurred Costs / Incurred Fee** | Controller-entered fields representing costs and fees already incurred against the ARA. |
| **Interest Impact** | A Controller-entered field on the CLIN worksheet (meaning not further defined in guide — see Ambiguities). |
| **Expected Burn Rate** | A Controller-entered field on the CLIN worksheet (meaning not further defined in guide — see Ambiguities). |
| **Revision** | A field on the ARA that changes when an ARA is rejected and resubmitted (tracking not fully defined in guide — see Ambiguities). |

---

### Constraints and System Requirements

- Must integrate with JAMIS for Org, CLIN, and Contract Number lookups
  and for ARA export.
- Must integrate with OMS for OMS Number lookups on Early Start ARAs.
- Must send automated email at every defined stage transition.
- Must support role-based access control for at minimum: Creator/PM,
  Contract Administrator, Controller, Approver.
- Must support the Approval & Threshold Matrix as a configurable system
  setting, not hard-coded logic.
- Must support multiple simultaneous Approvers in a sequential chain.
- Must track ARA status with at minimum: active in-progress states,
  Expired, Archived, Exported, Negated.
- Must maintain a Revision counter that increments on rejection cycles.
- Must support partial saves at every stage so users can complete forms
  across sessions.

---

### Ambiguities and Gaps — Resolve Before Migrating Affected Features

The following items are either not explained or inconsistent in the user
guide. Flag these to the product owner before implementing the affected
features.

1. **Approval & Threshold Matrix thresholds are undocumented.**
   The guide shows the matrix exists (Figure 7) but never states the
   dollar thresholds, number of approvers, or routing rules. Must obtain
   the actual matrix data before building approval routing logic.

2. **"Questions" on the ARA form are never listed.**
   The guide states questions appear on the PM and CA sections and are
   suppressed below $50K, but the actual questions are never enumerated.
   Must obtain the full question list with their $50K applicability flags.

3. **"Revision" field behavior is undefined.**
   The guide notes that Status and Revision change on rejection (Figures
   42–43) but never explains how Revision is calculated, incremented, or
   displayed. Clarify before building rejection/resubmission logic.

4. **"Interest Impact" and "Expected Burn Rate" are undefined.**
   Both are required Controller fields on the CLIN worksheet but neither
   is defined in the guide or glossary. Clarify data type, calculation
   source, and validation rules before building the Controller form.

5. **Early Start CA action list inconsistency.**
   The first action list for Early Start CA (Save / Upload Documents /
   Reject) omits "Submit for Next Approval," but the post-save action
   list does include it. Clarify whether Submit is available before
   document upload for Early Start, or only after.

6. **"Contract Manager" vs. "Contract Administrator" naming conflict.**
   Non-Early Start Step 2 labels the dropdown "Contract Manager," but
   all other references use "Contract Administrator." Confirm whether
   these are the same role or two distinct roles.

7. **Approver count and multi-approval chain is undefined.**
   The guide references "the next approver" repeatedly but never states
   how many approvers exist, whether they act in parallel or series, or
   what the terminal approval condition is. Must be resolved before
   building the approval routing engine.

8. **"Export to JAMIS" process is entirely absent.**
   The guide references Exported status and negation of Exported ARAs
   but never describes what triggers export, how it works, or what data
   is sent. Must document the export process before building it.

9. **Delegation configuration is not described.**
   The System Information page includes a Delegations section (Figure 6)
   but the guide does not explain what can be delegated, who can delegate,
   or how delegation affects workflow routing.

10. **OMS Number format and validation rules are not specified.**
    The guide says the field autocompletes from OMS data but provides no
    format constraints, minimum length, or error handling guidance.

11. **ARA expiration logic is not described.**
    The guide mentions an "Expired" status and a Dashboard showing
    "critical ARA expirations by expected expiration dates," but never
    explains how expiration dates are set, calculated, or what triggers
    the Expired status transition.

12. **Document upload file size and count limits are absent.**
    No maximum file size or maximum number of uploads per stage is stated.
    Confirm before building upload validation.

---

## Current Progress

### Phase 1 — Foundation

- [x] **Toolchain installed** — .NET 10.0.103 SDK, Node.js 24 (via Homebrew)
- [x] **Solution scaffolded** — `new/backend/ARA.slnx` with five projects:
  - `ARA.Api` — ASP.NET Core Web API (Microsoft.Identity.Web, FluentValidation.AspNetCore)
  - `ARA.Application` — Services and DTOs; `Result<T>` pattern in `Common/Result.cs`
  - `ARA.Domain` — Entities and repository interfaces (no external dependencies)
  - `ARA.Infrastructure` — Repository implementations (Dapper, Microsoft.Data.SqlClient)
  - `ARA.Application.Tests` — xUnit test project (Moq, FluentAssertions)
- [x] **Frontend scaffolded** — `new/frontend/` with Vite + React + TypeScript strict
  - Tailwind CSS v4 via `@tailwindcss/vite` plugin
  - shadcn/ui v3 initialized, design tokens in `src/index.css`
  - Folder structure: `components/ui/`, `hooks/`, `pages/`, `services/`, `types/`, `store/`
  - Path alias `@/` → `src/`
- [x] **`.gitignore`** created at repo root covering build artifacts, secrets, node_modules
- [x] **Verification passed** — `dotnet build` (0 errors), `dotnet test` (1 passed), `npm run build` (success)

### Phase 1 — Remaining

- [ ] Database connectivity — Dapper connection factory, stored procedure conventions
- [ ] Authentication — Entra ID configuration and middleware
- [ ] Core domain entities — `Ara`, `User`, `Role`, `Status`, `Category`

### Phase 2 — ARA Workflow (Not Started)

ARA creation → PM tab → Contract Administrator tab → Controller tab → Approval chain

### Resolved Ambiguities

None resolved yet. See User Guide Reference → Ambiguities and Gaps for the full list.
Prioritize items 1, 2, 7, and 8 before starting Phase 2 approval chain work.
