// Azure Static Web App for the Vite + React SPA.
//
// Recommended for the test/dev environment — handles HTTPS, custom domain,
// and env-var injection at deploy time. Free SKU is generous for this workload.
//
// GCC High note: Azure Static Web Apps may not be available in all GCC
// regions. If the prod target is hii.okta-gov.com and SWA is unavailable,
// swap this module for a second Container App that serves the built static
// files via nginx. The frontend Dockerfile would be ~10 lines.

@description('Resource name prefix, e.g. hii-ara-dev')
param namePrefix string

@description('Location for the Static Web App. SWA is regional but separate from the rest of the deployment — eastus2 is the closest Free-SKU region to West US 2 today.')
param location string = 'eastus2'

@description('SKU. Free for dev, Standard for prod (custom auth, SLA, BYO managed identity).')
@allowed([
  'Free'
  'Standard'
])
param sku string = 'Free'

@description('Tags applied to every resource in this module.')
param tags object = {}

resource staticWebApp 'Microsoft.Web/staticSites@2023-12-01' = {
  name: '${namePrefix}-spa'
  location: location
  tags: tags
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    // Build is wired up via GitHub Actions in a follow-up — Bicep
    // intentionally does not couple to a specific repo / branch / build path
    // so the IaC stays reusable across forks and prod-vs-test deployments.
    allowConfigFileUpdates: true
    stagingEnvironmentPolicy: 'Enabled'
    enterpriseGradeCdnStatus: 'Disabled'
  }
}

output staticWebAppName string = staticWebApp.name
output staticWebAppDefaultHostname string = staticWebApp.properties.defaultHostname
