// Log Analytics workspace + Application Insights, linked.
//
// App Insights stores its connection string in Key Vault (the consumer
// in Item 5 reads it from configuration via the Key Vault provider).

@description('Resource name prefix, e.g. hii-ara-dev')
param namePrefix string

@description('Azure region for all resources.')
param location string

@description('Tags applied to every resource in this module.')
param tags object = {}

// ── Log Analytics ──────────────────────────────────────────────────────────
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${namePrefix}-logs'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}

// ── Application Insights ──────────────────────────────────────────────────
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${namePrefix}-appi'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    IngestionMode: 'LogAnalytics'
  }
}

output logAnalyticsId string = logAnalytics.id
output logAnalyticsCustomerId string = logAnalytics.properties.customerId
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsName string = appInsights.name
