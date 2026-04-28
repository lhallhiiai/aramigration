// Container Registry + Container Apps Environment + API Container App.
//
// The API Container App uses a system-assigned managed identity so it can:
//   - Read secrets from Key Vault (role assigned by the secrets module)
//   - Authenticate to Azure SQL via "Authentication=Active Directory Default"
//     (SQL AD admin assignment is an out-of-band step — see runbook)
//
// First-deploy uses a public placeholder image. CI/CD pushes the real image
// to ACR in a follow-up; the Container App revision is then updated by the
// deploy script (or a GitHub Action) without re-running Bicep.

@description('Resource name prefix, e.g. hii-ara-dev')
param namePrefix string

@description('Azure region for all resources.')
param location string

@description('Tags applied to every resource in this module.')
param tags object = {}

@description('Log Analytics workspace customer ID.')
param logAnalyticsCustomerId string

@description('Log Analytics workspace resource ID, used to look up the shared key.')
param logAnalyticsId string

@description('Application Insights connection string (passed as env var, NOT via Key Vault on first boot — avoids the chicken/egg of the MI not yet having KV access).')
param appInsightsConnectionString string

@description('Key Vault URI the API reads at boot.')
param keyVaultUri string

@description('Container image for the API. Defaults to a public placeholder for first deploy.')
param apiImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('Okta authorization server issuer URI.')
param oktaIssuer string

@description('Okta API audience.')
param oktaAudience string = 'api://default'

@description('Allowed CORS origins for the API. Typically the frontend hostname(s).')
param allowedOrigins array = []

@description('ASP.NET Core environment name.')
param aspNetCoreEnvironment string = 'Production'

// ── Container Registry ────────────────────────────────────────────────────
resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: replace('${namePrefix}acr', '-', '')
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

// ── Container Apps Environment ────────────────────────────────────────────
resource containerAppsEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: '${namePrefix}-cae'
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: listKeys(logAnalyticsId, '2023-09-01').primarySharedKey
      }
    }
  }
}

// ── API Container App ─────────────────────────────────────────────────────
resource apiApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: '${namePrefix}-api'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppsEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
        allowInsecure: false
      }
      registries: []
    }
    template: {
      containers: [
        {
          name: 'api'
          image: apiImage
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: aspNetCoreEnvironment
            }
            {
              name: 'ASPNETCORE_URLS'
              value: 'http://+:8080'
            }
            {
              name: 'KeyVaultUri'
              value: keyVaultUri
            }
            {
              name: 'Okta__Issuer'
              value: oktaIssuer
            }
            {
              name: 'Okta__Audience'
              value: oktaAudience
            }
            {
              name: 'ApplicationInsights__ConnectionString'
              value: appInsightsConnectionString
            }
            {
              name: 'AllowedOrigins__0'
              value: length(allowedOrigins) > 0 ? allowedOrigins[0] : ''
            }
          ]
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                path: '/health/live'
                port: 8080
              }
              periodSeconds: 30
              failureThreshold: 3
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/health/ready'
                port: 8080
              }
              periodSeconds: 30
              failureThreshold: 3
              initialDelaySeconds: 10
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

// ACR pull permission for the Container App MI.
var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: registry
  name: guid(registry.id, apiApp.id, acrPullRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalId: apiApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output registryName string = registry.name
output registryLoginServer string = registry.properties.loginServer
output containerAppsEnvName string = containerAppsEnv.name
output apiAppName string = apiApp.name
output apiAppFqdn string = apiApp.properties.configuration.ingress.fqdn
output apiPrincipalId string = apiApp.identity.principalId
