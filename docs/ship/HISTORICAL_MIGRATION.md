# Historical Data Migration — `ara_legacy` → `ara_new`

This document covers Item 1 of `docs/SHIP_PLAN.md`: migrating historical ARA records from the legacy schema into the new PascalCase schema.

## Background

The legacy ARA application stored its data in a `dbo`-only database with lowercase / snake_case table and column names (e.g. `ara`, `ara_PM`, `clins`, `id_ara`). The new application uses PascalCase (`Ara`, `AraPmSection`, `Clin`, `AraId`).

Migration is a **two-stage** process when the production source is on a different network than the target Azure SQL instance:

1. **Stage 1 (`scripts/Copy-AraProductionData.ps1`)** — Copies the 26 legacy tables from a read-only production database into a corporate-network landing database that preserves the legacy schema (no FKs).
2. **Stage 2 (`scripts/Invoke-AraDataMigration.ps1`)** — Reads from the legacy schema (the landing database from Stage 1, or any other DB hosting the legacy schema) and writes into the new PascalCase schema in `ara_new`.

If the legacy source is already accessible from the same network as the target (as is the case in our current dev environment, where `ara_legacy` and `ara_new` live on the same Azure SQL server), Stage 1 is unnecessary — run Stage 2 directly against `ara_legacy`.

## Idempotency

`Invoke-AraDataMigration.ps1` is **destructively idempotent**: Phase 1 of the script clears every target table in reverse FK-dependency order, then reloads everything from source. Re-running with the same source produces the same final state with no duplicates.

This means:

- Re-running is safe — but it **wipes** anything currently in `ara_new`. If anyone has created test data in `ara_new` post-migration, it will be lost.
- The script always re-inserts the dev user (`EntraObjectId = dev-user-00000000`) after the User migration, so local-dev access is preserved.
- Identity values are preserved end-to-end: legacy `id_ara` becomes the new `AraId` directly via `SET IDENTITY_INSERT ... ON` and `SqlBulkCopy` with `KeepIdentity`.

## Prerequisites

- **Target schema applied:** All migration scripts in `scripts/sql/` (001–006) have been run against `ara_new`.
- **Azure CLI logged in:** `az login` against the subscription that owns `lhall-ara-dev-westus2`. The script uses `az account get-access-token --resource https://database.windows.net/` to authenticate.
- **Network access:** Both source and target Azure SQL servers must be reachable. The current dev firewall on `lhall-ara-dev-westus2` already allows `135.237.185.199` (`DevWin11Box`).
- **PowerShell `SqlServer` module:** Auto-installed to `$HOME/.psmodules` on first run if not already present.

## Invocation (current dev environment)

```powershell
# Run from the repo root, in PowerShell (Windows or PowerShell 7+):
.\scripts\Invoke-AraDataMigration.ps1 `
    -SourceConnectionString "Server=lhall-ara-dev-westus2.database.windows.net;Database=ara_legacy;Encrypt=True;TrustServerCertificate=False;" `
    -TargetServer "lhall-ara-dev-westus2.database.windows.net" `
    -TargetDatabase "ara_new"
```

Both source and target use Azure AD auth — the `az login` token is injected for both connections automatically (the script detects `.database.windows.net` in either connection string).

## When to re-run

Re-run the script when an updated copy of `ara_legacy` is provided. Typical sequence:

1. DBA / IT delivers an updated `ara_legacy` (either as a fresh restore on the same Azure SQL instance or via a `.bacpac` imported into a new database).
2. Confirm the legacy connection details (server, database).
3. Re-run the command above with the updated `Database=` value if the database name changed.
4. Verify row counts in `ara_new` match the new source counts (the script prints a per-table summary at the end).

## Verification

After every run, verify:

1. **Row counts per table match between source and target** — the script prints a summary in its final output.
2. **Spot-check a few ARAs end-to-end:**

   ```sql
   -- pick a few representative AraIds (ones that exist in legacy)
   SELECT id_ara, reference, division, contractNo, amountTotal, id_status, id_cat
   FROM ara_legacy.dbo.ara
   WHERE id_ara IN (5000, 7500);

   SELECT AraId, Reference, Division, ContractNumber, AmountTotal, StatusId, CategoryId
   FROM ara_new.dbo.Ara
   WHERE AraId IN (5000, 7500);
   ```

3. **Sections, CLINs, attachments, and approval log** for those AraIds are present in `ara_new`.

## Known facts about historical data

These were discovered during 2026-04-28 verification:

- The legacy ARA database has **no Costpoint / JAMIS reference tables**. Org, Contract Number, and CLIN entries are all stored as `varchar(50)` free-text on the relevant rows.
- All 11,716 historical CLIN rows in legacy have `CameFromJamis = 0`. The pre-population feature was never used in production. CLAUDE.md was updated on 2026-04-28 to reflect that the new system matches this free-text behavior.
- Legacy `ara` row count: 7,561. New `Ara` row count after migration: 7,561.
- Legacy `users` row count: 1,130. New `User` row count after migration: 1,131 (the +1 is the dev user inserted by the script).

For column-level mapping details, see `SCHEMA_MAPPING.md` in this same folder.
