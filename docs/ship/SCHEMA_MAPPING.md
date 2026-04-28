# Legacy → New Schema Mapping

This document captures the table-level mapping between the legacy `ara_legacy` schema and the new `ara_new` schema used by the historical data migration script (`scripts/Invoke-AraDataMigration.ps1`). For column-level mapping detail, see the `Migrate-Table` calls in that script — they are the source of truth.

## Table mapping (in migration order)

| Phase | Legacy table        | New table                | Identity preserved? | Notes |
| ----- | ------------------- | ------------------------ | ------------------- | ----- |
| 2     | `role`              | `Role`                   | yes                 | |
| 2     | `sector`            | `Sector`                 | yes (no IDENTITY)   | `Sector` has fixed IDs in source, no auto-increment |
| 2     | `jobTitle`          | `JobTitle`               | yes (no IDENTITY)   | `inactive` mapped to `IsInactive`, NULL → 0 |
| 2     | `category`          | `Category`               | yes                 | |
| 2     | `status`            | `Status`                 | yes                 | |
| 2     | `esReason`          | `EarlyStartReason`       | yes                 | |
| 2     | `revenueDescr`      | `RevenueDescription`     | yes                 | `Descr` → `Description` |
| 2     | `customerType`      | `CustomerType`           | yes                 | |
| 2     | `rejectionReason`   | `RejectionReason`        | yes                 | `Descr` → `Description` |
| 2     | `emailTypes`        | `EmailType`              | yes                 | `email_type` → `EmailType`; `long_description` → `LongDescription` |
| 2     | `thresholds`        | `Threshold`              | yes                 | `low_thresh` → `LowThreshold`; `delegate` → `CanDelegate` |
| 2     | `attach_checklist`  | `AttachmentRequirement`  | yes                 | `who` → `ApplicableRole` |
| 2     | `Cat_Questions_Map` | `QuestionMap`            | yes                 | `tab` → `Tab`; `ods_or_user` → `SourceType` |
| 3     | `users`             | `User`                   | yes                 | Deduped by `oprid` (ROW_NUMBER over partition); NULL `oprid` → placeholder `legacy-user-{id}`; duplicates suffixed `-dup{id}`. Script also appends a dev user (`EntraObjectId = dev-user-00000000`). |
| 4     | `ara`               | `Ara`                    | yes                 | Free-text `division`, `contractNo` carried over verbatim. `ID_Contract` → `ContractAdministratorId`. |
| 5     | `ara_PM`            | `AraPmSection`           | yes                 | One row per ARA. |
| 5     | `ara_cm`            | `AraCaSection`           | yes                 | One row per ARA (Contract Manager / Contract Administrator section). |
| 5     | `ara_con`           | `AraControllerSection`   | yes                 | One row per ARA. |
| 6     | `clins`             | `Clin`                   | yes                 | Per-ARA child entries. `CameFromJamis` is preserved but always 0 in historical data. |
| 7     | `araAppLog`         | `AraApprovalLog`         | yes                 | Approval audit trail. ~303,359 rows. |
| 7     | `araAppList`        | `AraApprovalAssignment`  | yes                 | Currently 0 rows in legacy. |
| 8     | `attachments`       | `AraAttachment`          | yes                 | Binary file content optionally migrated; flag-controlled in `Copy-AraProductionData.ps1` (`-SkipBinaryAttachments`). |
| 9     | `delegation`        | `Delegation`             | yes                 | |
| 10    | `emailLog`          | `EmailLog`               | yes                 | Historical email log. ~56K rows. |
| 11    | `logbook`           | `AuditLog`               | yes                 | |
| 12    | `ara_export_archive`| `AraExportArchive`       | yes                 | JAMIS export records (legacy / OBE feature). |

Total: 26 source tables → 26 target tables.

## Identity policy

Every `Migrate-Table` call uses `SqlBulkCopyOptions.KeepIdentity`, with `SET IDENTITY_INSERT ... ON` wrapped around the copy. Result: legacy IDs are preserved 1:1 in the new schema. Cross-references between rows (e.g. `Ara.AraId` ↔ `Clin.AraId`, `Ara.ProgramManagerId` ↔ `User.UserId`) survive intact.

## Things deliberately NOT migrated

- **No new schema added to support Costpoint validation** — the legacy app never validated Org / Contract Number / CLIN against any reference source. The new app matches that behavior. See `CLAUDE.md` (2026-04-28 update) for the policy.
- **Auto-generated lookup-table IDs** — for tables where the new schema uses `IDENTITY(1,1)`, the script still preserves source IDs via `SET IDENTITY_INSERT`. This is intentional: it keeps FK references (e.g. `User.RoleId`) consistent across legacy → new.

## When the schema changes

When a future migration (007+) alters a table that this script touches, update the corresponding `Migrate-Table` call (column mappings + select query). The script is the single point of truth for column-level mapping; this document only summarizes table-level structure and policy.
