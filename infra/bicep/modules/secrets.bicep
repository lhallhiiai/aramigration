// Key Vault (RBAC mode) + role assignments.
//
// Two seed secrets are stored:
//   - ConnectionStrings--AraDatabase    → wired into appsettings via Key Vault provider
//   - ApplicationInsights--ConnectionString
//
// Bicep does NOT manage rotation; secret values are passed in once and
// rotated via az/az-cli or the portal afterwards. Empty values short-circuit
// secret creation so the same template can run before the API image exists.

@description('Resource name prefix, e.g. hii-ara-dev')
param namePrefix string

@description('Azure region for all resources.')
param location string

@description('Tags applied to every resource in this module.')
param tags object = {}

@description('Tenant ID for Key Vault. Defaults to the deployment tenant.')
param tenantId string = subscription().tenantId

@description('Principal ID of the Container App managed identity that consumes secrets.')
param consumerPrincipalId string

@description('Principal ID of the human/service principal that may write secrets out of band. Optional.')
param writerPrincipalId string = ''

@description('Connection string for the AraDatabase. Pass empty to skip seeding (secret can be set later).')
@secure()
param araDatabaseConnectionString string = ''

@description('Application Insights connection string. Pass empty to skip seeding.')
@secure()
param appInsightsConnectionString string = ''

// Built-in role IDs.
var keyVaultSecretsUserRoleId = '4633458b-17de-43eb-b23c-c4b65b21a8d8'
var keyVaultSecretsOfficerRoleId = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'

// ── Key Vault ──────────────────────────────────────────────────────────────
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${namePrefix}-kv'
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Enabled'
  }
}

// Container App MI gets read access to secrets.
resource consumerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, consumerPrincipalId, keyVaultSecretsUserRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: consumerPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Optional: a human/service principal that can rotate secrets.
resource writerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(writerPrincipalId)) {
  scope: keyVault
  name: guid(keyVault.id, writerPrincipalId, keyVaultSecretsOfficerRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsOfficerRoleId)
    principalId: writerPrincipalId
  }
}

// ── Seed secrets (only created when a value is supplied) ──────────────────
resource araDbSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(araDatabaseConnectionString)) {
  parent: keyVault
  name: 'ConnectionStrings--AraDatabase'
  properties: {
    value: araDatabaseConnectionString
  }
}

resource appInsightsSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(appInsightsConnectionString)) {
  parent: keyVault
  name: 'ApplicationInsights--ConnectionString'
  properties: {
    value: appInsightsConnectionString
  }
}

output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
