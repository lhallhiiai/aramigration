# ARA API — Smoke Test Procedure

Generated: 2026-02-21

## Prerequisites — do these once per terminal session

### 1. Log in to Azure CLI

The connection string uses `Authentication=Active Directory Default`, so your local Azure
identity must be authenticated before the API can reach Azure SQL.

```bash
az login
az account set --subscription "HII Commercial Sandbox"
```

Confirm the correct subscription is active:

```bash
az account show --query name -o tsv
```

### 2. Set up the .NET PATH

```bash
export DOTNET_ROOT="/opt/homebrew/opt/dotnet/libexec"
export PATH="$DOTNET_ROOT:$PATH"
```

Verify: `dotnet --version` should print `10.0.103`.

---

## Step 1 — Start the API

```bash
dotnet run --project /Users/louishall/git/ara/new/backend/src/ARA.Api/ARA.Api.csproj
```

Wait for both of these lines before sending any requests:

```
Now listening on: http://localhost:5081
Now listening on: https://localhost:7117
```

Confirm the dev auth bypass is active — this log line must appear:

```
info: ARA.Api.Middleware.DevAuthenticationHandler[0]
      Dev authentication bypass active – authenticated as dev@local.dev
```

If the bypass line is absent, check that `appsettings.Development.json` has `TenantId: ""`
(no code change is needed — an empty TenantId activates the bypass automatically).

---

## Step 2 — Health check (no auth required)

Run from the REST Client file (`new/backend/requests/ara-api.http`) or curl:

```bash
curl -s http://localhost:5081/health
```

**Expected: `200 OK` — body: `Healthy`**

If this fails, the API process is not running or is bound to a different port.
Check the terminal output from Step 1.

---

## Step 3 — SMOKE 1: Categories

This is the primary smoke test. It exercises the full stack:

```
dev auth bypass → [Authorize] → CategoriesController → CategoryService
  → CategoryRepository → Azure SQL → JSON response
```

```bash
curl -s http://localhost:5081/api/categories | python3 -m json.tool
```

**Expected: `200 OK`** with an array of seeded categories:

```json
[
  { "categoryId": 1, "categoryName": "Award Fees", "riskLevel": "Medium", "color": "..." },
  { "categoryId": 2, "categoryName": "Mod Pending (Incremental Funding)", ... }
]
```

A successful response confirms:

- Dev auth bypass is authorizing requests correctly
- The connection string resolves to Azure SQL
- Your Azure CLI identity has read access to the database
- The seed data from `002_seed_data.sql` is present
- The full Application → Infrastructure → Domain → SQL chain is wired correctly

---

## Step 4 — SMOKE 2: Job titles

```bash
curl -s http://localhost:5081/api/job-titles | python3 -m json.tool
```

**Expected: `200 OK`** with an array of seeded job titles.

Confirms a second reference table is seeded and accessible.

---

## Step 5 — SMOKE 3: Current user

```bash
curl -s http://localhost:5081/api/users/me | python3 -m json.tool
```

This calls `ICurrentUserService`, which looks up the dev user (`dev-user-00000000`)
in the `User` table.

- **`200 OK`** — the dev user row exists. The stack is fully operational.
- **`404 Not Found`** — the dev user row is missing. See fix below.

### Fix: seed the dev user

If SMOKE 3 returns 404, run this directly against Azure SQL (`hii-ara-dev-db`):

```sql
INSERT INTO [dbo].[User] (EntraObjectId, DisplayName, Email, JobTitleId, IsActive, CreatedAt)
VALUES ('dev-user-00000000', 'Dev User', 'dev@local.dev', 1, 1, GETUTCDATE());
```

Then retry `GET /api/users/me`.

---

## All requests in one place

All requests are in `new/backend/requests/ara-api.http`. Open that file in VS Code
(requires the **REST Client** extension — `humao.rest-client`) and click **Send Request**
above each `###` block.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `curl: Connection refused` | API not running | Check terminal output from Step 1 |
| `401 Unauthorized` on `/api/categories` | Dev bypass not active | Confirm `TenantId` is empty in `appsettings.Development.json` |
| `500 Internal Server Error` on `/api/categories` | DB connection failed | Check `az account show`; confirm IP is allowed in Azure SQL firewall |
| Empty array `[]` from `/api/categories` | Seed data not applied | Confirm `001_schema.sql` and `002_seed_data.sql` were deployed |
| `/api/users/me` returns 404 | Dev user row missing | Run the INSERT above |
| `Login failed for user '<token-identified principal>'` in logs | Azure identity lacks DB access | Grant your identity `db_datareader` + `db_datawriter` on `hii-ara-dev-db` |

---

## Pass criteria

All three smokes must return `200 OK` with non-empty JSON before the stack is
considered verified. Proceed to unit tests and the React frontend once all three pass.
See [OUTSTANDINGWORK.md](OUTSTANDINGWORK.md) for the recommended order of attack.
