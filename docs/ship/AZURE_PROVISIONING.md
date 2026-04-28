## Azure Provisioning + First-Deploy Runbook

This document covers the Bicep templates in `infra/bicep/` and the manual steps required around them. It's the deliverable companion to the Item 8 deferred work and a prerequisite for Items 6 line-by-line sign-off.

**Status:** Bicep is **drafted, not applied**. Per CLAUDE.md ("New Azure resources" requires explicit authorization), the templates land in source so they can be reviewed and applied when the team is ready. The PowerShell wrapper defaults to a what-if preview and only applies on `-Apply`.

---

### Architecture

```
Resource Group (ARA-Dev-Work | <prod RG>)
├── hii-ara-<env>-logs           Log Analytics workspace (30d retention, 1GB/day cap)
├── hii-ara-<env>-appi           Application Insights (workspace-based, linked to logs)
├── hii-ara-<env>-kv             Key Vault (RBAC mode)
│       │  ConnectionStrings--AraDatabase    ← seeded if value passed at deploy
│       │  ApplicationInsights--ConnectionString ← seeded from observability output
│       └─ role assignments
│              Container App MI → Key Vault Secrets User
│              keyVaultRotatorPrincipalId → Key Vault Secrets Officer (optional)
├── hiiara<env>acr               Container Registry (Basic; no admin user)
├── hii-ara-<env>-cae            Container Apps Environment (logs to LAW)
├── hii-ara-<env>-api            Container App (system-assigned MI)
│       Ingress: external, port 8080
│       Liveness:  GET /health/live   every 30s
│       Readiness: GET /health/ready  every 30s, 10s initial delay
│       Replicas: 1–3
│       Env vars: KeyVaultUri, Okta__Issuer, Okta__Audience, ApplicationInsights__ConnectionString, AllowedOrigins__0, ASPNETCORE_*
└── hii-ara-<env>-spa            Static Web App (Free SKU, eastus2)
```

**Not managed by Bicep:**

- Resource Group itself (create via `az group create` first; the deploy script handles this)
- Azure SQL Server / Database (already exists in dev — `lhall-ara-dev-westus2`. Provision the prod equivalent separately when the prod environment is greenlit.)
- SQL AD admin or DB role assignments to the Container App MI (manual — see "Post-deploy" below)
- Static Web App build pipeline (wired via GitHub Actions in a follow-up)

---

### Why this shape

**Backend → Azure Container Apps.** Already specified in CLAUDE.md. Right fit for a single ASP.NET Core API: managed scale, Key Vault + SQL via Managed Identity, free-tier-friendly, no cluster ops.

**Frontend → Azure Static Web Apps (recommendation).** Vite SPA serves cleanly from SWA: HTTPS, custom domain, env-var injection at build time, GitHub Actions integration, generous Free SKU. Trade-off vs containerizing:

- ✅ Significantly less to operate (no Dockerfile, no image to push, no revision to bump)
- ✅ Cheaper at this scale
- ⚠️ **GCC High caveat:** Azure Static Web Apps may not be available in all GCC regions when the prod target migrates to `hii.okta-gov.com`. If SWA is unavailable in the chosen GCC region, replace `modules/frontend.bicep` with a second Container App that runs nginx serving the built `dist/` folder (a ~10-line Dockerfile). The rest of the template is unchanged.

**Container Registry → Basic SKU.** Sufficient for this workload. Upgrade to Standard or Premium later if tighter network controls (private endpoints, VNet integration) become a requirement.

**Application Insights → workspace-based.** Required for new App Insights resources. Logs go to the linked Log Analytics workspace; one place to query app telemetry + container logs.

**Key Vault → RBAC, not access policies.** Microsoft's recommended default since 2022. Role assignments live in Bicep alongside the vault.

---

### Files

```
infra/bicep/
├── main.bicep                       Top-level orchestrator, targetScope=resourceGroup
├── main.parameters.dev.json         Test-tenant Okta values, dev name prefix
├── main.parameters.prod.json        <TBD> placeholders for prod Okta + SWA hostname
└── modules/
    ├── observability.bicep          LAW + App Insights
    ├── secrets.bicep                Key Vault + role assignments + seed secrets
    ├── compute.bicep                ACR + Container Apps Env + API Container App
    └── frontend.bicep               Static Web App
```

```
scripts/
└── Deploy-AzureInfrastructure.ps1   Wrapper: az login check → group create → what-if → apply
```

Bicep validates clean (`az bicep build` returns exit 0 with no warnings).

---

### Deployment

#### Pre-flight (one-time, per environment)

1. **Az CLI signed in.** `az login` and `az account set --subscription "Azure subscription 1"`.
2. **Resource group exists** (the script creates it idempotently, but you may want to choose the name):
   - dev: `ARA-Dev-Work` (already exists)
   - prod: `<TBD: e.g. ARA-Prod>`
3. **Subscription contributor** rights for the deployer principal (your user account or an SP).

#### Preview (no changes applied)

```powershell
./scripts/Deploy-AzureInfrastructure.ps1 -Environment dev -ResourceGroup ARA-Dev-Work
```

The script runs `az deployment group what-if` and prints the planned changes. **Nothing is applied.** Review the output before continuing.

#### Apply

```powershell
./scripts/Deploy-AzureInfrastructure.ps1 -Environment dev -ResourceGroup ARA-Dev-Work -Apply
```

After apply, the script prints the resource names and FQDNs for the next steps.

#### Prod deployment

Same script, swap `-Environment prod -ResourceGroup <prod RG>`. **Before applying:** fill in the `<TBD>` values in `main.parameters.prod.json` (prod Okta issuer, SWA hostname for CORS allowlist, optional rotator principal ID).

---

### Post-deploy (manual — Bicep cannot do these cleanly)

#### 1. Grant the Container App MI access to Azure SQL

Bicep cannot reliably set Azure AD admins or create contained users in Azure SQL without extra hops. From SSMS or `sqlcmd` against the SQL DB, as a SQL AD admin:

```sql
CREATE USER [hii-ara-<env>-api] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [hii-ara-<env>-api];
ALTER ROLE db_datawriter ADD MEMBER [hii-ara-<env>-api];
GRANT EXECUTE TO [hii-ara-<env>-api];     -- stored procedures (per CLAUDE.md, no inline SQL)
```

The user name must match the **Container App name** (`hii-ara-<env>-api`); that's how Azure SQL resolves the MI.

#### 2. Seed the AraDatabase connection string

If you didn't pass `araDatabaseConnectionString` at deploy time:

```powershell
az keyvault secret set `
    --vault-name hii-ara-<env>-kv `
    --name 'ConnectionStrings--AraDatabase' `
    --value 'Server=<sql-server>.database.windows.net;Database=ara_new;Authentication=Active Directory Default;Encrypt=True;'
```

The double-dash `--` is the Key Vault → IConfiguration colon-segment delimiter.

#### 3. Push the real API image and update the container app

The first deploy uses a public hello-world placeholder. To deploy the real API:

```powershell
$acr = 'hiiara<env>acr'
az acr login --name $acr
$image = "$acr.azurecr.io/ara-api:$(git rev-parse --short HEAD)"

docker build -t $image new/backend
docker push $image

az containerapp update `
    --name hii-ara-<env>-api `
    --resource-group <RG> `
    --image $image
```

Ongoing image deploys live in CI (GitHub Actions in a follow-up); this is the manual fallback.

#### 4. Wire the Static Web App build pipeline

In the Azure Portal or via `az staticwebapp update`, link the SWA to this GitHub repo. Source path: `new/frontend/`, output: `dist/`, build command: `npm run build`. Inject `VITE_OKTA_*` and `VITE_API_BASE_URL` at deploy time.

---

### Cost expectations

Sizing for the test/dev environment, assuming low traffic:

| Resource | SKU | Monthly est. (USD) |
| --- | --- | --- |
| Log Analytics | PerGB, 1 GB/day cap | ~$3 |
| Application Insights | workspace-based | included in LAW cost |
| Key Vault | Standard | < $1 (per-operation) |
| Container Registry | Basic | $5 |
| Container Apps Environment | consumption | ~$0 idle, ~$10 with steady traffic |
| Container App (1–3 replicas, 0.5 vCPU / 1 GiB) | consumption | ~$15 at typical dev load |
| Static Web App | Free | $0 |
| **Total estimate** | | **~$25–35 / month** |

Azure SQL is separate and already provisioned in dev; expect a similar tier in prod.

---

### Cleanup (if you ever need it)

```powershell
az group delete --name <RG> --yes --no-wait
```

Soft-deleted Key Vaults stick around for 7 days (configured in `secrets.bicep`). Re-deploying with the same name in that window will fail unless you purge the soft-deleted vault first:

```powershell
az keyvault purge --name hii-ara-<env>-kv
```
