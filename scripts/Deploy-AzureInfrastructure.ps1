<#
.SYNOPSIS
    Deploys ARA Azure infrastructure from infra/bicep/main.bicep.

.DESCRIPTION
    Wraps the four steps required to stand up (or update) the ARA Azure
    resources for a given environment:

      1. az login (skipped if already signed in to the right subscription)
      2. az group create — idempotent
      3. az deployment group what-if — dry-run preview
      4. az deployment group create — apply

    What-if always runs first and prints the planned changes. Apply requires
    -Apply on the command line; without it the script stops after the
    preview.

.PARAMETER Environment
    Which parameter file to use. Maps to infra/bicep/main.parameters.<env>.json.

.PARAMETER ResourceGroup
    Target resource group name. Created if it does not exist.

.PARAMETER Location
    Azure region. Defaults to westus2 (per CLAUDE.md).

.PARAMETER SubscriptionId
    Optional subscription ID. If omitted, the current az context is used.

.PARAMETER Apply
    Switch. Required to actually apply changes. Without it, the script runs
    what-if only and exits.

.EXAMPLE
    # Preview the dev deployment
    ./scripts/Deploy-AzureInfrastructure.ps1 -Environment dev -ResourceGroup ARA-Dev-Work

.EXAMPLE
    # Apply the dev deployment
    ./scripts/Deploy-AzureInfrastructure.ps1 -Environment dev -ResourceGroup ARA-Dev-Work -Apply

.NOTES
    See docs/ship/AZURE_PROVISIONING.md for the full runbook including
    out-of-band steps (SQL AD admin assignment, secret seeding) that must
    happen after this script completes.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('dev', 'prod')]
    [string]$Environment,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [string]$Location = 'westus2',

    [string]$SubscriptionId,

    [switch]$Apply
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$bicepFile = Join-Path $repoRoot 'infra/bicep/main.bicep'
$parametersFile = Join-Path $repoRoot "infra/bicep/main.parameters.$Environment.json"

if (-not (Test-Path $bicepFile)) {
    throw "Bicep template not found: $bicepFile"
}
if (-not (Test-Path $parametersFile)) {
    throw "Parameters file not found: $parametersFile"
}

Write-Host "==> ARA Azure deployment ($Environment → $ResourceGroup in $Location)"

# ── Subscription context ──────────────────────────────────────────────────
if ($SubscriptionId) {
    Write-Host "==> Setting subscription context: $SubscriptionId"
    az account set --subscription $SubscriptionId | Out-Null
}

$currentSub = (az account show --query '{name:name, id:id}' -o json | ConvertFrom-Json)
Write-Host "    Current subscription: $($currentSub.name) ($($currentSub.id))"

# ── Resource group ────────────────────────────────────────────────────────
$rgExists = (az group exists --name $ResourceGroup) -eq 'true'
if (-not $rgExists) {
    Write-Host "==> Creating resource group: $ResourceGroup in $Location"
    az group create --name $ResourceGroup --location $Location | Out-Null
} else {
    Write-Host "==> Resource group exists: $ResourceGroup"
}

# ── What-if preview ───────────────────────────────────────────────────────
Write-Host "==> Running what-if preview"
az deployment group what-if `
    --resource-group $ResourceGroup `
    --template-file $bicepFile `
    --parameters "@$parametersFile"

if (-not $Apply) {
    Write-Host ''
    Write-Host '==> Preview complete. Re-run with -Apply to deploy.'
    return
}

# ── Apply ─────────────────────────────────────────────────────────────────
Write-Host ''
Write-Host '==> Applying deployment'
$deploymentName = "ara-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

$result = az deployment group create `
    --name $deploymentName `
    --resource-group $ResourceGroup `
    --template-file $bicepFile `
    --parameters "@$parametersFile" `
    --query 'properties.outputs' `
    -o json | ConvertFrom-Json

Write-Host ''
Write-Host '==> Deployment outputs'
Write-Host "    API FQDN:                 $($result.apiFqdn.value)"
Write-Host "    API container app:        $($result.apiAppName.value)"
Write-Host "    Container Registry:       $($result.containerRegistryLoginServer.value)"
Write-Host "    Key Vault URI:            $($result.keyVaultUri.value)"
Write-Host "    Key Vault name:           $($result.keyVaultName.value)"
Write-Host "    Application Insights:     $($result.appInsightsName.value)"
Write-Host "    Static Web App hostname:  $($result.staticWebAppHostname.value)"
Write-Host "    Static Web App name:      $($result.staticWebAppName.value)"
Write-Host ''
Write-Host '==> Next manual steps (see docs/ship/AZURE_PROVISIONING.md):'
Write-Host '    1. Assign the API container app managed identity as a SQL AD user with the required roles.'
Write-Host '    2. Seed the AraDatabase connection string into Key Vault if it was not passed at deploy time.'
Write-Host '    3. Push your API image to ACR and update the container app revision.'
Write-Host '    4. Configure the Static Web App build / deploy pipeline (typically via GitHub Actions).'
