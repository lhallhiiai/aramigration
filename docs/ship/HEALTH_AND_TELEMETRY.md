## Health Checks + Application Insights

This document covers the readiness/liveness probes and the Application Insights wiring. It's the deliverable companion to Item 5 of `docs/SHIP_PLAN.md`.

### Endpoints

| Endpoint         | Predicate                       | Purpose                                                                                                       |
| ---------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `GET /health/live`  | `_ => false` — runs no checks    | Liveness probe. Returns `200 Healthy` when the process can answer HTTP. K8s/Container Apps uses this to decide whether to restart the container. |
| `GET /health/ready` | tagged `ready` — all three checks | Readiness probe. Returns JSON with overall status + per-check details. Front-door / load balancer should pull the instance out of rotation on `503`. |

Status mapping for `/health/ready`:

- All `Healthy` → `200`, body `{"status":"Healthy",...}`
- Any `Degraded`, none `Unhealthy` → `200`, body `{"status":"Degraded",...}` — caller should not page, but the operator should investigate
- Any `Unhealthy` → `503`, body `{"status":"Unhealthy",...}` — caller should page

### Custom checks

All three live in `new/backend/src/ARA.Infrastructure/HealthChecks/` and are registered with the tag `ready` in `Program.cs`.

#### `SqlConnectivityHealthCheck`

Opens a connection through `IDbConnectionFactory` and runs `SELECT 1`. Healthy when the round-trip completes; Unhealthy with the exception attached when the open or the probe fails.

#### `KeyVaultHealthCheck`

When `KeyVaultUri` is unset (typical local dev — see `LOCAL_DEV_SECRETS.md`), reports **Degraded** with an explanatory message rather than failing. In any environment where `KeyVaultUri` is set, the check fetches one page of secret properties via `SecretClient.GetPropertiesOfSecretsAsync`. This validates both network reachability AND that the calling identity (Container App Managed Identity in prod) holds list permission on the vault. An empty vault still reports Healthy — the goal is to prove reachability + auth, not to assert a specific secret exists.

#### `OktaMetadataHealthCheck`

When `Okta:Issuer` is unset (the dev-auth bypass path in `Program.cs`), reports **Degraded**. When set, GETs `{issuer}/.well-known/openid-configuration` via a typed `HttpClient` with a 5 second timeout. The JWT bearer middleware itself fetches the same document at startup and refreshes periodically; an outage here means tokens cannot be validated and every signed-in request will 401. The 5 second timeout is a hard cap so a hung Okta endpoint cannot block the readiness probe past the next scheduled scrape.

### Application Insights

`Program.cs` calls `AddApplicationInsightsTelemetry`, reading the connection string from `ApplicationInsights:ConnectionString`. **There is no source-controlled fallback** — `appsettings.json` ships with the value as an empty string. The two real sources are:

1. **Production** — Key Vault, surfaced into `IConfiguration` by the `AddAzureKeyVault` call earlier in `Program.cs`. Set the secret name to `ApplicationInsights--ConnectionString` so the Key Vault → config bridge maps it to the expected colon-delimited key.
2. **Local dev** — `dotnet user-secrets set "ApplicationInsights:ConnectionString" "<value>"`. Optional. When unset, the SDK no-ops and telemetry is simply not published — local runs do not need an App Insights resource.

The Application Insights resource itself is part of the Item 8 Azure-resource provisioning deferral. The wiring is in place so that flipping the connection string in Key Vault is the only step needed once the resource exists.

### Verification

Local smoke (with no Key Vault and dev-auth bypass active):

```powershell
dotnet run --project new/backend/src/ARA.Api --urls http://localhost:5099
# in another terminal:
curl http://localhost:5099/health/live              # → 200, empty body
curl http://localhost:5099/health/ready             # → 200, status=Degraded
```

Expected `/health/ready` body in local-dev mode (formatted):

```json
{
  "status": "Degraded",
  "totalDurationMs": 98.5,
  "results": {
    "sql":      { "status": "Healthy",  "description": "AraDatabase reachable.", ... },
    "keyvault": { "status": "Degraded", "description": "KeyVaultUri is not configured. ...", ... },
    "okta":     { "status": "Degraded", "description": "Okta:Issuer is not configured. ...", ... }
  }
}
```

Production smoke checklist (deferred to Item 6 prod-readiness): all three checks `Healthy`; overall `200`; App Insights ingesting telemetry within 60 seconds of first request.

DB-outage simulation: stop SQL access (e.g. revoke the Container App Managed Identity from the database) → `/health/ready` returns `503` with `sql` reporting `Unhealthy` and the exception captured in `error`. Restore access → status returns to `Healthy` on the next scrape.
