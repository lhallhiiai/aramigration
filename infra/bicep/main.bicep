// ARA Azure infrastructure — top-level orchestrator.
//
// Targets a pre-existing resource group. Apply with:
//   az deployment group create -g <rg> -f main.bicep -p main.parameters.<env>.json
//
// What this template DOES create:
//   - Log Analytics workspace + Application Insights
//   - Key Vault (RBAC) + role assignments + seed secrets
//   - Container Registry + Container Apps Environment + API Container App
//   - Static Web App for the frontend
//
// What this template DOES NOT create:
//   - Resource group itself (create out of band: az group create)
//   - Azure SQL Server / Database (already exists in dev; provision prod separately)
//   - SQL AD admin or DB role assignments to the Container App MI
//     (manual step — see docs/ship/AZURE_PROVISIONING.md "Post-deploy")
//
// First deploy uses a placeholder API image; CI pushes the real image
// to ACR and updates the Container App revision in a follow-up.

targetScope = 'resourceGroup'

@description('Resource name prefix, e.g. hii-ara-dev. Used to name every resource.')
param namePrefix string

@description('Azure region for all resources. Static Web App may differ — see frontend module.')
param location string = resourceGroup().location

@description('ASP.NET Core environment name passed to the API container.')
param aspNetCoreEnvironment string = 'Production'

@description('Okta authorization server issuer URI passed to the API container.')
param oktaIssuer string

@description('Okta API audience.')
param oktaAudience string = 'api://default'

@description('Allowed CORS origins for the API. Typically the SWA hostname.')
param allowedOrigins array = []

@description('AraDatabase connection string seeded into Key Vault. Pass empty to skip seeding (set later via az keyvault secret set).')
@secure()
param araDatabaseConnectionString string = ''

@description('Container image for the API. Defaults to a public placeholder.')
param apiImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('Optional principal ID (AAD object ID of a user, group, or SP) granted Key Vault Secrets Officer for out-of-band rotation. This is an object ID, not a secret value.')
param keyVaultRotatorPrincipalId string = ''

@description('Standard tags applied to every resource.')
param tags object = {
  application: 'ARA'
  managedBy: 'Bicep'
}

// ── Observability ─────────────────────────────────────────────────────────
module observability 'modules/observability.bicep' = {
  name: 'observability'
  params: {
    namePrefix: namePrefix
    location: location
    tags: tags
  }
}

// ── Compute (registry, env, API) ──────────────────────────────────────────
module compute 'modules/compute.bicep' = {
  name: 'compute'
  params: {
    namePrefix: namePrefix
    location: location
    tags: tags
    logAnalyticsCustomerId: observability.outputs.logAnalyticsCustomerId
    logAnalyticsId: observability.outputs.logAnalyticsId
    appInsightsConnectionString: observability.outputs.appInsightsConnectionString
    // environment().suffixes.keyvaultDns is "vault.azure.net" in Public,
    // "vault.usgovcloudapi.net" in GCC High — keeps this template portable
    // for the eventual hii.okta-gov.com migration.
    keyVaultUri: 'https://${namePrefix}-kv${environment().suffixes.keyvaultDns}/'
    apiImage: apiImage
    oktaIssuer: oktaIssuer
    oktaAudience: oktaAudience
    allowedOrigins: allowedOrigins
    aspNetCoreEnvironment: aspNetCoreEnvironment
  }
}

// ── Secrets (Key Vault + role assignments + seed values) ──────────────────
// Depends on compute.outputs.apiPrincipalId; runs after compute completes.
module secrets 'modules/secrets.bicep' = {
  name: 'secrets'
  params: {
    namePrefix: namePrefix
    location: location
    tags: tags
    consumerPrincipalId: compute.outputs.apiPrincipalId
    writerPrincipalId: keyVaultRotatorPrincipalId
    araDatabaseConnectionString: araDatabaseConnectionString
    appInsightsConnectionString: observability.outputs.appInsightsConnectionString
  }
}

// ── Frontend ──────────────────────────────────────────────────────────────
module frontend 'modules/frontend.bicep' = {
  name: 'frontend'
  params: {
    namePrefix: namePrefix
    tags: tags
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────
output apiFqdn string = compute.outputs.apiAppFqdn
output apiAppName string = compute.outputs.apiAppName
output containerRegistryLoginServer string = compute.outputs.registryLoginServer
output keyVaultUri string = secrets.outputs.keyVaultUri
output keyVaultName string = secrets.outputs.keyVaultName
output appInsightsName string = observability.outputs.appInsightsName
output staticWebAppHostname string = frontend.outputs.staticWebAppDefaultHostname
output staticWebAppName string = frontend.outputs.staticWebAppName
