## User Provisioning (Okta JIT + Admin Onboarding)

This document covers how authenticated Okta users acquire a row in the local `dbo.[User]` table. It's the deliverable companion to Item 4 of `docs/SHIP_PLAN.md`.

There are two provisioning paths:

1. **JIT (Just-in-Time)** — automatic, runs on the first authenticated request from an unknown caller. The request itself triggers the provisioning.
2. **Admin onboard** — explicit, runs when an admin POSTs to `/api/admin/users/provision` with a known Okta `sub`. Used to seed users before any sign-in (e.g. background processes that authenticate without going through the SPA).

Both paths flow through `IUserProvisioningService`, which delegates to the idempotent stored procedure `dbo.usp_UserProvision` (defined in `scripts/sql/007_user_provisioning.sql`). Re-running either path against an existing user is a no-op SELECT — no duplicates, no churn.

**Authorization rule for production:** any user granted access to the application in Okta gets access. There is no per-user gate inside the app itself. The Item 4 ship-plan note holds: tightening `/api/admin/users/provision` to an admin-only role is tracked under the future role-management story.

---

### JIT flow

`JitUserProvisioningMiddleware` is registered in `Program.cs` between `UseAuthentication()` and `UseAuthorization()`. For every authenticated request:

1. Reads the principal's claims (see claim map below).
2. Calls `IUserProvisioningService.ProvisionFromClaimsAsync(principal, ct)`.
3. On success, the request continues to the controller pipeline as normal.
4. On hard failure (missing required claims, DB unreachable, etc.) it short-circuits with HTTP 500 and a Problem Details payload.

Unauthenticated requests pass through without provisioning, so anonymous endpoints (e.g. `/health`) are unaffected.

---

### Claim → column map

Read in this order (first non-empty wins):

| Local column     | Okta JWT claim (production)                       | Dev fallback (`DevAuthenticationHandler`)            | Required? |
| ---------------- | ------------------------------------------------- | ---------------------------------------------------- | --------- |
| `ExternalUserId` | `sub`                                             | `ClaimTypes.NameIdentifier`                          | yes       |
| `Email`          | `ClaimTypes.Email`, then `email`                  | same                                                 | yes       |
| `DisplayName`    | `ClaimTypes.Name`, then `name`, then "first last" | same; falls back to email when nothing else is set   | yes       |
| `FirstName`      | `ClaimTypes.GivenName`, then `given_name`         | same                                                 | no        |
| `LastName`       | `ClaimTypes.Surname`, then `family_name`          | same                                                 | no        |
| `RoleId`         | n/a — defaulted to `1` (Creator/PM)               | n/a                                                  | n/a       |

Notes:
- `ExternalUserId` and `Email` are hard requirements. A token missing either fails JIT with HTTP 500 and a clear log line; the Okta application must include the `email` scope.
- `RoleId` always defaults to `1` (Creator/PM), matching the existing dev-user precedent in `Invoke-AraDataMigration.ps1`. Role elevation is out of scope for Item 4 — admins use direct SQL or a future user-management endpoint.
- `DevAuthenticationHandler` only sets `NameIdentifier`; production JWT bearer middleware also maps `sub` to `NameIdentifier`. The fallback chain handles both.

---

### Admin onboard endpoint

```
POST /api/admin/users/provision
Authorization: Bearer <token>
Content-Type: application/json

{
  "externalUserId": "00uxxxxxxxxxxxxxx",
  "email":          "person@example.com",
  "displayName":    "Person Example",
  "firstName":      "Person",
  "lastName":       "Example"
}
```

Validation (FluentValidation, `AdminProvisionUserRequestValidator`):

- `externalUserId` — required, ≤ 100 chars
- `email` — required, valid email, ≤ 255 chars
- `displayName` — required, ≤ 500 chars
- `firstName` / `lastName` — optional, each ≤ 100 chars

Responses:

- `200 OK` — returns the user row that ends up in the database (existing or newly created)
- `400 Bad Request` — validation failure or service-level rejection (returned in the `Result.Error` body)
- `401 Unauthorized` — missing or invalid bearer token

Idempotent: re-POSTing the same `externalUserId` returns the existing row unchanged.

---

### GCC High quirk

On `hii.okta-gov.com` (the GCC High tenant), `credentials.provider.*` filter paths are **disabled** by Okta. Any directory queries against the Okta API must scope by **app integration**, not by provider filter.

The current implementation does not query the Okta directory — it consumes claims that are already on the authenticated principal — so this restriction has no effect on JIT or the admin-onboard endpoint today. If a future feature adds a "search Okta users" admin endpoint, the implementation must scope by app integration; otherwise it will fail in GCC High with an authorization error.

This quirk is also called out in the XML doc on `JitUserProvisioningMiddleware` so future code changes don't reintroduce a forbidden filter pattern.

---

### Failure mode by design

`CurrentUserService.GetCurrentUserAsync` no longer logs-and-returns-null when the authenticated caller has no local row. With JIT in front, that state is impossible by construction; if it ever occurs it indicates a configuration bug (middleware not registered, claims unreadable, DB write rolled back). The method now throws `InvalidOperationException`, which the global error path renders as HTTP 500 with diagnostics in logs. **No silent failures.**

---

### Smoke test (manual)

1. Confirm the Okta test app emits `email`, `given_name`, `family_name`, `name`. (Item 2's `LOCAL_DEV_SECRETS.md` covers test-tenant config.)
2. Sign into the SPA as a user who is **not** present in `dbo.[User]`.
3. Run any authenticated API call (e.g. `GET /api/users/me`).
4. Verify the call succeeds. In SQL: `SELECT * FROM dbo.[User] WHERE ExternalUserId = '<your sub>'` — one row.
5. Sign in again as the same user and repeat. Same row, no duplicate.

For the admin path:

1. POST to `/api/admin/users/provision` with a known Okta `sub` (any authenticated bearer token works for now).
2. `200` returns the row. Re-POST returns the same row unchanged.
