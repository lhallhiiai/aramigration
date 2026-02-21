<#
.SYNOPSIS
    Provisions or removes the ARA development Azure SQL server and database.

.DESCRIPTION
    Manages ARA development Azure SQL resources in the HII Commercial Sandbox subscription.
    The Provision action is fully idempotent and safe to run multiple times.
    The Remove action tears everything down completely to eliminate cost when not in use.

    Prerequisites:
      - Azure CLI (az) installed and available in PATH
      - Logged in via: az login
      - Contributor rights on the ARA-Dev-Work resource group (or Subscription)

    Auth strategy:
      Interactive connections use Azure AD (Active Directory Default).
      A SQL admin account is created as a fallback only; its password is never stored.

.PARAMETER Action
    Provision  Creates the SQL server and database. Safe to re-run — already-existing
               resources are detected and skipped.
    Remove     Deletes the SQL server and all its databases to stop all billing.
               The resource group itself is left intact.

.PARAMETER SqlAdminPassword
    Required on the very first Provision when the SQL server does not yet exist.
    Omit on subsequent runs (server already exists) and on Remove.
    If the server does not exist and this parameter is omitted, the script will
    prompt securely at runtime.

.EXAMPLE
    # First-time setup (prompts for admin password if not supplied)
    .\scripts\Manage-AraDatabase.ps1 -Action Provision

    # Tear down to eliminate cost
    .\scripts\Manage-AraDatabase.ps1 -Action Remove

    # Restore when development resumes
    .\scripts\Manage-AraDatabase.ps1 -Action Provision
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Provision', 'Remove')]
    [string] $Action,

    [string]       $Subscription    = 'Azure subscription 1',
    [string]       $ResourceGroup   = 'ARA-Dev-Work',
    [string]       $Location        = 'westus2',
    [string]       $SqlServerName   = 'hii-ara-dev-sql',
    [string]       $DatabaseName    = 'hii-ara-dev-db',
    [string]       $SqlAdminLogin   = 'araadmin',
    [SecureString] $SqlAdminPassword
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Console helpers ────────────────────────────────────────────────────────────

function Write-Step([string] $Message) {
    Write-Host "`n  ▶  $Message" -ForegroundColor Cyan
}

function Write-Done([string] $Message) {
    Write-Host "     ✓  $Message" -ForegroundColor Green
}

function Write-Skipped([string] $Message) {
    Write-Host "     –  $Message already exists, skipping." -ForegroundColor DarkGray
}

function Write-Warn([string] $Message) {
    Write-Host "     ⚠  $Message" -ForegroundColor Yellow
}

function Write-Separator {
    Write-Host ('-' * 68) -ForegroundColor DarkGray
}

# ── Utility ────────────────────────────────────────────────────────────────────

function ConvertTo-PlainText([SecureString] $SecureString) {
    return [System.Net.NetworkCredential]::new('', $SecureString).Password
}

function Invoke-Az {
    param([string[]] $Arguments)
    $result = az @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "az $($Arguments[0]) $($Arguments[1]) failed: $result"
    }
    return $result
}

# ── Prerequisites ──────────────────────────────────────────────────────────────

function Assert-Prerequisites {
    Write-Step 'Checking prerequisites'

    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        throw 'Azure CLI is not installed or not in PATH. See: https://aka.ms/installazurecli'
    }
    Write-Done 'Azure CLI found'

    $accountJson = az account show 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $accountJson) {
        throw 'Not logged in to Azure. Run: az login'
    }

    $account = $accountJson | ConvertFrom-Json
    Write-Done "Logged in as: $($account.user.name)"
}

function Set-ActiveSubscription {
    Write-Step "Setting active subscription to '$Subscription'"
    Invoke-Az @('account', 'set', '--subscription', $Subscription) | Out-Null
    Write-Done "Subscription active"
}

# ── Provision steps ────────────────────────────────────────────────────────────

function Confirm-ResourceGroup {
    Write-Step "Resource group: $ResourceGroup"

    $existing = az group show --name $ResourceGroup 2>$null | ConvertFrom-Json
    if ($existing) {
        Write-Skipped $ResourceGroup
        return
    }

    Invoke-Az @('group', 'create', '--name', $ResourceGroup, '--location', $Location) | Out-Null
    Write-Done "Resource group '$ResourceGroup' created in $Location"
}

function Confirm-SqlServer([string] $PlainPassword) {
    Write-Step "SQL server: $SqlServerName"

    $existing = az sql server show `
        --resource-group $ResourceGroup `
        --name $SqlServerName 2>$null | ConvertFrom-Json

    if ($existing) {
        Write-Skipped $SqlServerName
        return
    }

    if ([string]::IsNullOrWhiteSpace($PlainPassword)) {
        throw "SQL server '$SqlServerName' does not exist and -SqlAdminPassword was not provided. " +
              'Supply a password for first-time provisioning.'
    }

    Invoke-Az @(
        'sql', 'server', 'create',
        '--resource-group',  $ResourceGroup,
        '--name',            $SqlServerName,
        '--location',        $Location,
        '--admin-user',      $SqlAdminLogin,
        '--admin-password',  $PlainPassword,
        '--enable-public-network', 'true'
    ) | Out-Null

    Write-Done "SQL server '$SqlServerName' created"
    Write-Warn "SQL admin login '$SqlAdminLogin' is a fallback only. Use Azure AD for all connections."
}

function Set-SqlAzureAdAdmin {
    Write-Step 'Setting Azure AD admin on SQL server'

    $meJson = az ad signed-in-user show 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $meJson) {
        Write-Warn 'Could not retrieve signed-in Azure AD user. Set the AD admin manually:'
        Write-Host "       az sql server ad-admin create --resource-group $ResourceGroup --server-name $SqlServerName --display-name <name> --object-id <oid>" -ForegroundColor DarkGray
        return
    }

    $me = $meJson | ConvertFrom-Json

    $result = az sql server ad-admin create `
        --resource-group $ResourceGroup `
        --server-name    $SqlServerName `
        --display-name   $me.displayName `
        --object-id      $me.id 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Warn "Could not set Azure AD admin (may already be configured): $result"
    } else {
        Write-Done "Azure AD admin set to: $($me.displayName) ($($me.userPrincipalName))"
    }
}

function Confirm-Database {
    Write-Step "Database: $DatabaseName"

    $existing = az sql db show `
        --resource-group $ResourceGroup `
        --server         $SqlServerName `
        --name           $DatabaseName 2>$null | ConvertFrom-Json

    if ($existing) {
        Write-Skipped $DatabaseName
        return
    }

    # Serverless General Purpose: billed per second of compute only while active.
    # Auto-pauses after 60 minutes of inactivity — zero compute cost when idle.
    Invoke-Az @(
        'sql', 'db', 'create',
        '--resource-group',  $ResourceGroup,
        '--server',          $SqlServerName,
        '--name',            $DatabaseName,
        '--edition',         'GeneralPurpose',
        '--family',          'Gen5',
        '--capacity',        '2',
        '--compute-model',   'Serverless',
        '--auto-pause-delay','60',
        '--zone-redundant',  'false'
    ) | Out-Null

    Write-Done "Database '$DatabaseName' created (Serverless Gen5, 2 vCores max, auto-pause 60 min)"
}

function Set-FirewallRules {
    Write-Step 'Configuring firewall'

    # 0.0.0.0 → 0.0.0.0 is the Azure magic range that allows all Azure services.
    Invoke-Az @(
        'sql', 'server', 'firewall-rule', 'create',
        '--resource-group', $ResourceGroup,
        '--server',         $SqlServerName,
        '--name',           'AllowAzureServices',
        '--start-ip-address', '0.0.0.0',
        '--end-ip-address',   '0.0.0.0'
    ) | Out-Null
    Write-Done 'Azure services access rule set'

    # Add this machine's current public IP.
    try {
        $myIp    = (Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 8).Trim()
        $ruleName = "DevMachine-$([System.Environment]::MachineName)"

        Invoke-Az @(
            'sql', 'server', 'firewall-rule', 'create',
            '--resource-group',   $ResourceGroup,
            '--server',           $SqlServerName,
            '--name',             $ruleName,
            '--start-ip-address', $myIp,
            '--end-ip-address',   $myIp
        ) | Out-Null

        Write-Done "Firewall rule added for current IP: $myIp  (rule: $ruleName)"
    } catch {
        Write-Warn 'Could not detect public IP. Add your IP manually in the Azure portal under the SQL server firewall settings.'
    }
}

function Show-ConnectionStrings {
    $fqdn = "$SqlServerName.database.windows.net"

    Write-Host ''
    Write-Separator
    Write-Host '  Connection strings — paste the chosen value into appsettings.Development.json' -ForegroundColor White
    Write-Host '  That file is gitignored and safe to hold credentials.' -ForegroundColor DarkGray
    Write-Separator

    Write-Host "`n  Option A — Azure AD / your own account (recommended for dev):" -ForegroundColor Yellow
    Write-Host "  Server=$fqdn;Database=$DatabaseName;Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;" -ForegroundColor White

    Write-Host "`n  Option B — SQL admin fallback (avoid checking in):" -ForegroundColor Yellow
    Write-Host "  Server=$fqdn;Database=$DatabaseName;User Id=$SqlAdminLogin;Password=<password>;Encrypt=True;TrustServerCertificate=False;" -ForegroundColor White

    Write-Host "`n  Production — Container Apps Managed Identity (no secrets):" -ForegroundColor Yellow
    Write-Host "  Server=$fqdn;Database=$DatabaseName;Authentication=Active Directory Managed Identity;Encrypt=True;TrustServerCertificate=False;" -ForegroundColor White

    Write-Host ''
    Write-Separator
    Write-Host ''
}

# ── Remove steps ───────────────────────────────────────────────────────────────

function Remove-SqlDatabase {
    Write-Step "Deleting database: $DatabaseName"

    $existing = az sql db show `
        --resource-group $ResourceGroup `
        --server         $SqlServerName `
        --name           $DatabaseName 2>$null | ConvertFrom-Json

    if (-not $existing) {
        Write-Skipped "$DatabaseName not found"
        return
    }

    Invoke-Az @(
        'sql', 'db', 'delete',
        '--resource-group', $ResourceGroup,
        '--server',         $SqlServerName,
        '--name',           $DatabaseName,
        '--yes'
    ) | Out-Null

    Write-Done "Database '$DatabaseName' deleted"
}

function Remove-SqlServer {
    Write-Step "Deleting SQL server: $SqlServerName"

    $existing = az sql server show `
        --resource-group $ResourceGroup `
        --name           $SqlServerName 2>$null | ConvertFrom-Json

    if (-not $existing) {
        Write-Skipped "$SqlServerName not found"
        return
    }

    Invoke-Az @(
        'sql', 'server', 'delete',
        '--resource-group', $ResourceGroup,
        '--name',           $SqlServerName,
        '--yes'
    ) | Out-Null

    Write-Done "SQL server '$SqlServerName' deleted (all databases and firewall rules removed)"
}

# ── Entry point ────────────────────────────────────────────────────────────────

try {
    Write-Host ''
    Write-Host "  ARA Database Manager  |  Action: $Action" -ForegroundColor White
    Write-Separator

    Assert-Prerequisites
    Set-ActiveSubscription

    switch ($Action) {

        'Provision' {
            # Resolve the SQL admin password. Only needed when the server does not yet exist.
            $serverExists = az sql server show `
                --resource-group $ResourceGroup `
                --name $SqlServerName 2>$null | ConvertFrom-Json

            [string] $plainPassword = ''

            if (-not $serverExists) {
                if ($SqlAdminPassword) {
                    $plainPassword = ConvertTo-PlainText $SqlAdminPassword
                } else {
                    Write-Host "`n  SQL server does not exist yet. Enter a password for the SQL admin account '$SqlAdminLogin'." -ForegroundColor Yellow
                    Write-Host "  This is a fallback credential only — connections will use Azure AD auth." -ForegroundColor DarkGray
                    $prompted = Read-Host -Prompt '  Password' -AsSecureString
                    $plainPassword = ConvertTo-PlainText $prompted
                }
            }

            Confirm-ResourceGroup
            Confirm-SqlServer   $plainPassword
            Set-SqlAzureAdAdmin
            Confirm-Database
            Set-FirewallRules
            Show-ConnectionStrings

            Write-Host "  Provisioning complete." -ForegroundColor Green
            Write-Host "  Next step: paste a connection string above into new/backend/src/ARA.Api/appsettings.Development.json`n" -ForegroundColor DarkGray
        }

        'Remove' {
            Write-Host ''
            Write-Warn "This will permanently delete '$DatabaseName' and the server '$SqlServerName'."
            Write-Warn "All data will be lost. The resource group '$ResourceGroup' is left intact."
            Write-Host ''
            $confirm = Read-Host "  Type 'yes' to confirm"

            if ($confirm -ne 'yes') {
                Write-Host "`n  Aborted. No changes made.`n" -ForegroundColor DarkGray
                exit 0
            }

            Remove-SqlDatabase
            Remove-SqlServer

            Write-Host "`n  Removal complete. Run with -Action Provision to restore when needed.`n" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "`n  ✗  Error: $_`n" -ForegroundColor Red
    exit 1
}
