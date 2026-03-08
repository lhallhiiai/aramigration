<#
.SYNOPSIS
    Provisions ARA databases and manages firewall access in a personal Azure tenant.

.DESCRIPTION
    Creates and manages two Azure SQL databases (ara_legacy and ara_new) on a single
    logical SQL server in your personal Azure tenant.

    Both databases are provisioned as Serverless Gen5 with the minimum vCore count,
    local backup redundancy, and a 60-minute auto-pause. When no connection is open
    for 60 minutes the compute shuts down entirely and you pay only for storage
    (~$0.115/GB/month). An empty database uses well under 1 GB.

    Cost summary (approximate West US 2 / East US pricing):
      Compute  : $0.000145 / vCore-second while active (0.5 vCore min)
      Storage  : ~$0.115 / GB / month (local redundancy)
      Idle cost: ~$0.00 / day when both databases are auto-paused
      Active   : ~$0.20-0.40 / day if used a few hours per day across both DBs

    To stop ALL cost when not in use:
      1. Run -Action Remove (deletes server + databases; re-provision in ~3 minutes).
      2. Or simply stop connecting — both databases auto-pause within 60 minutes.
         The first query after a pause takes ~30 seconds while the database resumes.

    On first Provision, the script:
      1. Creates (or skips) the resource group and SQL server.
      2. Sets you as the Azure AD admin on the server.
      3. Creates ara_legacy and ara_new (Serverless Gen5, 0.5–1 vCore, auto-pause 60 min).
      4. Creates a SQL login and grants it db_owner on both databases.
      5. Opens the server firewall to the machine running this script.

    AddFirewallIp and RemoveFirewallIp operate at the SQL server level. Because both
    databases share the same logical server, one firewall rule covers both.

    Prerequisites:
      - Azure CLI (az) installed and in PATH
      - Logged in via: az login
      - Contributor rights on the target resource group or subscription
      - PowerShell SqlServer module (installed automatically if missing)

.PARAMETER Action
    Provision        Creates the SQL server, ara_legacy, ara_new, and a SQL login.
    Remove           Deletes the SQL server and all its databases permanently.
    AddFirewallIp    Opens the server firewall to a specific IP address.
    RemoveFirewallIp Closes an existing firewall rule by IP address.

.PARAMETER IpAddress
    The IPv4 address to allow or remove. Required for AddFirewallIp and RemoveFirewallIp.

.PARAMETER FirewallRuleName
    Optional name for the firewall rule. Defaults to "Custom-<IP-with-dashes>".
    When removing, the script matches by name first; if omitted it matches by start IP.

.PARAMETER Subscription
    Azure subscription name or ID. Defaults to the currently active subscription.

.PARAMETER ResourceGroup
    Azure resource group name. Defaults to 'ARA-Personal-Work'.

.PARAMETER Location
    Azure region. Defaults to 'eastus'.

.PARAMETER SqlServerName
    Name of the Azure SQL logical server to create/manage. Must be globally unique.

.PARAMETER SqlAdminLogin
    Server-level SQL administrator username. Used only during initial server creation.

.PARAMETER SqlAdminPassword
    Password for the SQL administrator. Prompted securely if the server does not yet
    exist and this parameter is omitted.

.PARAMETER DbUserLogin
    Name of the application SQL login to create with db_owner on both databases.
    Prompted if omitted during Provision.

.PARAMETER DbUserPassword
    Password for the application SQL login. Prompted securely if omitted during Provision.

.EXAMPLE
    # First-time setup
    .\scripts\Manage-PersonalDatabases.ps1 -Action Provision -SqlServerName 'yourname-ara-sql'

.EXAMPLE
    # Open access from a specific IP
    .\scripts\Manage-PersonalDatabases.ps1 -Action AddFirewallIp -SqlServerName 'yourname-ara-sql' -IpAddress '203.0.113.42'

.EXAMPLE
    # Remove that IP
    .\scripts\Manage-PersonalDatabases.ps1 -Action RemoveFirewallIp -SqlServerName 'yourname-ara-sql' -IpAddress '203.0.113.42'

.EXAMPLE
    # Tear everything down to eliminate all cost
    .\scripts\Manage-PersonalDatabases.ps1 -Action Remove -SqlServerName 'yourname-ara-sql'
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Provision', 'Remove', 'AddFirewallIp', 'RemoveFirewallIp')]
    [string] $Action,

    [string]       $IpAddress,
    [string]       $FirewallRuleName,

    [string]       $Subscription,
    [string]       $ResourceGroup   = 'ARA-Personal-Work',
    [string]       $Location        = 'eastus',

    [Parameter(Mandatory)]
    [string]       $SqlServerName,

    [string]       $SqlAdminLogin   = 'araadmin',
    [SecureString] $SqlAdminPassword,

    [string]       $DbUserLogin,
    [SecureString] $DbUserPassword
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

[string] $LegacyDatabase = 'ara_legacy'
[string] $NewDatabase    = 'ara_new'

# Regions tried in order when the primary location rejects new SQL server provisioning.
[string[]] $FallbackRegions = @('eastus2', 'westus2', 'centralus', 'northcentralus', 'westus', 'eastus')

# ── Console helpers ─────────────────────────────────────────────────────────────

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

# ── Utilities ───────────────────────────────────────────────────────────────────

function ConvertTo-PlainText([SecureString] $Secure) {
    return [System.Net.NetworkCredential]::new('', $Secure).Password
}

function Invoke-Az {
    param([string[]] $Arguments)
    [string] $result = az @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "az $($Arguments[0]) $($Arguments[1]) failed: $result"
    }
    return $result
}

function Assert-SafeSqlIdentifier([string] $Value, [string] $ParamName) {
    if ($Value -notmatch '^[A-Za-z][A-Za-z0-9_]{0,127}$') {
        throw "$ParamName '$Value' is not a valid SQL identifier. Use only letters, digits, and underscores; must start with a letter."
    }
}

function Get-SqlAccessToken {
    [string] $token = az account get-access-token `
        --resource 'https://database.windows.net' `
        --query    accessToken `
        --output   tsv 2>&1

    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($token)) {
        throw "Failed to obtain an Azure AD access token for Azure SQL. Ensure you are logged in via 'az login'."
    }

    return $token.Trim()
}

function Invoke-SqlStatement([string] $ServerFqdn, [string] $Database, [string] $AccessToken, [string] $Query) {
    Invoke-Sqlcmd `
        -ServerInstance $ServerFqdn `
        -Database       $Database `
        -AccessToken    $AccessToken `
        -Query          $Query `
        -ErrorAction    Stop
}

# ── Module check ────────────────────────────────────────────────────────────────

function Assert-SqlServerModule {
    Write-Step 'Checking SqlServer PowerShell module'

    if (Get-Module -ListAvailable -Name SqlServer) {
        Write-Done 'SqlServer module available'
        Import-Module SqlServer -ErrorAction Stop
        return
    }

    Write-Warn 'SqlServer module not found. Installing for current user (no admin required)...'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module -Name SqlServer -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
    Import-Module SqlServer -ErrorAction Stop
    Write-Done 'SqlServer module installed and imported'
}

# ── Prerequisites ───────────────────────────────────────────────────────────────

function Assert-Prerequisites {
    Write-Step 'Checking prerequisites'

    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        throw 'Azure CLI is not installed or not in PATH. See: https://aka.ms/installazurecli'
    }
    Write-Done 'Azure CLI found'

    [string] $accountJson = az account show 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $accountJson) {
        throw 'Not logged in to Azure. Run: az login'
    }

    $account = $accountJson | ConvertFrom-Json
    Write-Done "Logged in as: $($account.user.name)"
}

function Set-ActiveSubscription {
    if ([string]::IsNullOrWhiteSpace($Subscription)) {
        [string] $currentSub = (az account show --query name --output tsv 2>$null).Trim()
        Write-Step "Using active subscription: $currentSub"
        return
    }

    Write-Step "Setting active subscription to '$Subscription'"
    Invoke-Az @('account', 'set', '--subscription', $Subscription) | Out-Null
    Write-Done 'Subscription active'
}

# ── Provision steps ─────────────────────────────────────────────────────────────

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

function Confirm-SqlServer([string] $ServerSecret) {
    Write-Step "SQL server: $SqlServerName"

    # Build a deduplicated region list: requested location first, then fallbacks.
    [System.Collections.Generic.List[string]] $regions = [System.Collections.Generic.List[string]]::new()
    $regions.Add($Location)
    foreach ($r in $FallbackRegions) {
        if ($r -ne $Location) { $regions.Add($r) }
    }

    # Each attempt uses a region-specific name (e.g. lhall-ara-sql-eastus2) so that
    # no two attempts ever share a name. This avoids InvalidResourceLocation entirely.
    # Check whether any region-specific variant already exists before trying to create.
    foreach ($region in $regions) {
        [string] $candidateName = "$SqlServerName-$region"
        [string] $showResult = az sql server show `
            --resource-group $ResourceGroup `
            --name           $candidateName 2>$null

        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($showResult)) {
            [string] $existingRegion = ($showResult | ConvertFrom-Json).location
            Write-Skipped "$candidateName (region: $existingRegion)"
            $script:SqlServerName = $candidateName
            $script:Location      = $existingRegion
            return
        }
    }

    if ([string]::IsNullOrWhiteSpace($ServerSecret)) {
        throw "SQL server does not exist and -SqlAdminPassword was not provided."
    }

    [bool] $created = $false
    foreach ($region in $regions) {
        [string] $candidateName = "$SqlServerName-$region"
        Write-Host "     Trying: $candidateName in $region" -ForegroundColor DarkGray

        [string] $result = az sql server create `
            --resource-group $ResourceGroup `
            --name           $candidateName `
            --location       $region `
            --admin-user     $SqlAdminLogin `
            --admin-password $ServerSecret 2>&1

        if ($LASTEXITCODE -eq 0) {
            $script:SqlServerName = $candidateName
            $script:Location      = $region
            $created = $true
            break
        }

        if ($result -match 'RegionDoesNotAllowProvisioning') {
            Write-Warn "Region '$region' is not accepting new SQL servers. Trying next region..."
            continue
        }

        throw "az sql server create failed: $result"
    }

    if (-not $created) {
        throw "SQL server creation failed in all attempted regions: $($regions -join ', '). " +
              "Check your subscription's regional quotas or try a different -Location."
    }

    Write-Done "SQL server '$($script:SqlServerName)' created in region '$($script:Location)'"
    Write-Warn "SQL admin '$SqlAdminLogin' is a break-glass account only. Use Azure AD or the app SQL login for day-to-day connections."
}

function Set-SqlAzureAdAdmin {
    Write-Step 'Setting Azure AD admin on SQL server'

    [string] $meJson = az ad signed-in-user show 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $meJson) {
        Write-Warn 'Could not retrieve signed-in Azure AD user. Set the AD admin manually in the Azure portal.'
        return
    }

    $me = $meJson | ConvertFrom-Json

    [string] $result = az sql server ad-admin create `
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

function Confirm-Database([string] $DbName) {
    Write-Step "Database: $DbName"

    $existing = az sql db show `
        --resource-group $ResourceGroup `
        --server         $SqlServerName `
        --name           $DbName 2>$null | ConvertFrom-Json

    if ($existing) {
        Write-Skipped $DbName
        return
    }

    # Cheapest Serverless configuration:
    #   - 1 vCore max, 0.5 vCore min  →  smallest possible compute bill
    #   - Auto-pause after 60 minutes  →  no compute charge when idle (60 min is the minimum)
    #   - Local backup redundancy      →  cheapest backup storage option
    #   - No zone redundancy           →  unnecessary for dev
    # Idle cost: storage only (~$0.115/GB/month; an empty DB is well under 1 GB)
    Invoke-Az @(
        'sql', 'db', 'create',
        '--resource-group',            $ResourceGroup,
        '--server',                    $SqlServerName,
        '--name',                      $DbName,
        '--edition',                   'GeneralPurpose',
        '--family',                    'Gen5',
        '--capacity',                  '1',
        '--min-capacity',              '0.5',
        '--compute-model',             'Serverless',
        '--auto-pause-delay',          '60',
        '--zone-redundant',            'false',
        '--backup-storage-redundancy', 'Local'
    ) | Out-Null

    Write-Done "Database '$DbName' created (Serverless Gen5, 0.5–1 vCore, auto-pause 60 min, local backup)"
}

function Confirm-CurrentMachineFirewallRule {
    Write-Step 'Ensuring firewall access for this machine'

    try {
        [string] $myIp    = (Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 8).Trim()
        [string] $ruleName = "Machine-$([System.Environment]::MachineName)"

        Invoke-Az @(
            'sql', 'server', 'firewall-rule', 'create',
            '--resource-group',   $ResourceGroup,
            '--server',           $SqlServerName,
            '--name',             $ruleName,
            '--start-ip-address', $myIp,
            '--end-ip-address',   $myIp
        ) | Out-Null

        Write-Done "Firewall rule '$ruleName' set to current IP: $myIp"
    } catch {
        Write-Warn 'Could not detect public IP. Use -Action AddFirewallIp to add your IP manually.'
    }
}

function Set-InitialFirewallRules {
    Write-Step 'Configuring base firewall rules'

    Invoke-Az @(
        'sql', 'server', 'firewall-rule', 'create',
        '--resource-group',   $ResourceGroup,
        '--server',           $SqlServerName,
        '--name',             'AllowAzureServices',
        '--start-ip-address', '0.0.0.0',
        '--end-ip-address',   '0.0.0.0'
    ) | Out-Null
    Write-Done 'Azure services access rule set'

    Confirm-CurrentMachineFirewallRule
}

function New-SqlLoginAndUsers([string] $Login, [string] $UserSecret) {
    Write-Step "Creating SQL login '$Login' with db_owner on both databases"

    Assert-SafeSqlIdentifier $Login '-DbUserLogin'

    [string] $serverFqdn    = "$SqlServerName.database.windows.net"
    [string] $accessToken   = Get-SqlAccessToken
    [string] $escapedSecret = $UserSecret -replace "'", "''"

    # Create the server-level login in master.
    [string] $createLoginSql =
        "IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'$Login') " +
        "BEGIN " +
        "CREATE LOGIN [$Login] WITH PASSWORD = N'$escapedSecret'; " +
        "END"

    Invoke-SqlStatement -ServerFqdn $serverFqdn -Database 'master' -AccessToken $accessToken -Query $createLoginSql
    Write-Done "SQL login '$Login' created on master"

    # Grant db_owner in each database.
    foreach ($db in @($LegacyDatabase, $NewDatabase)) {
        [string] $grantSql =
            "IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'$Login') " +
            "BEGIN " +
            "CREATE USER [$Login] FOR LOGIN [$Login]; " +
            "END; " +
            "ALTER ROLE db_owner ADD MEMBER [$Login];"

        Invoke-SqlStatement -ServerFqdn $serverFqdn -Database $db -AccessToken $accessToken -Query $grantSql
        Write-Done "User '$Login' granted db_owner on '$db'"
    }
}

function Show-ConnectionStrings([string] $Login) {
    [string] $fqdn = "$SqlServerName.database.windows.net"

    Write-Host ''
    Write-Separator
    Write-Host '  Connection strings — paste into appsettings.Development.json (gitignored)' -ForegroundColor White
    Write-Separator

    Write-Host "`n  ara_legacy — Azure AD / your own account (recommended):" -ForegroundColor Yellow
    Write-Host "  Server=$fqdn;Database=$LegacyDatabase;Authentication=Active Directory Default;Encrypt=True;" -ForegroundColor White

    Write-Host "`n  ara_legacy — SQL login ($Login):" -ForegroundColor Yellow
    Write-Host "  Server=$fqdn;Database=$LegacyDatabase;User Id=$Login;Password=<password>;Encrypt=True;" -ForegroundColor White

    Write-Host "`n  ara_new — Azure AD / your own account (recommended):" -ForegroundColor Yellow
    Write-Host "  Server=$fqdn;Database=$NewDatabase;Authentication=Active Directory Default;Encrypt=True;" -ForegroundColor White

    Write-Host "`n  ara_new — SQL login ($Login):" -ForegroundColor Yellow
    Write-Host "  Server=$fqdn;Database=$NewDatabase;User Id=$Login;Password=<password>;Encrypt=True;" -ForegroundColor White

    Write-Host ''
    Write-Separator
    Write-Host ''
}

function Show-CostGuidance {
    Write-Host '  Cost guidance' -ForegroundColor White
    Write-Separator
    Write-Host "  Both databases auto-pause after 60 minutes of inactivity." -ForegroundColor DarkGray
    Write-Host "  While paused you pay only for storage (< `$0.01/day for empty databases)." -ForegroundColor DarkGray
    Write-Host ''
    Write-Host '  To cut all cost when not in use:' -ForegroundColor Yellow
    Write-Host "    .\scripts\Manage-PersonalDatabases.ps1 -Action Remove -SqlServerName '$SqlServerName'" -ForegroundColor White
    Write-Host ''
    Write-Host '  To restore (takes ~3 minutes):' -ForegroundColor Yellow
    Write-Host "    .\scripts\Manage-PersonalDatabases.ps1 -Action Provision -SqlServerName '$SqlServerName'" -ForegroundColor White
    Write-Host ''
    Write-Host '  Note: the first query after an auto-pause takes ~30 seconds to resume.' -ForegroundColor DarkGray
    Write-Separator
    Write-Host ''
}

# ── Remove steps ────────────────────────────────────────────────────────────────

function Remove-SqlDatabase([string] $DbName) {
    Write-Step "Deleting database: $DbName"

    $existing = az sql db show `
        --resource-group $ResourceGroup `
        --server         $SqlServerName `
        --name           $DbName 2>$null | ConvertFrom-Json

    if (-not $existing) {
        Write-Skipped "$DbName not found"
        return
    }

    Invoke-Az @(
        'sql', 'db', 'delete',
        '--resource-group', $ResourceGroup,
        '--server',         $SqlServerName,
        '--name',           $DbName,
        '--yes'
    ) | Out-Null

    Write-Done "Database '$DbName' deleted"
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

    Write-Done "SQL server '$SqlServerName' deleted (all databases, logins, and firewall rules removed)"
}

# ── Firewall helpers ─────────────────────────────────────────────────────────────

function Assert-IpAddress([string] $Ip) {
    if ([string]::IsNullOrWhiteSpace($Ip)) {
        throw '-IpAddress is required for this action.'
    }
    if ($Ip -notmatch '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
        throw "'-IpAddress $Ip' does not look like a valid IPv4 address."
    }
}

function Get-DefaultRuleName([string] $Ip) {
    return "Custom-$($Ip -replace '\.', '-')"
}

function Add-FirewallIp([string] $Ip, [string] $RuleName) {
    Write-Step "Adding firewall rule for IP: $Ip"

    if ([string]::IsNullOrWhiteSpace($RuleName)) {
        $RuleName = Get-DefaultRuleName $Ip
    }

    Invoke-Az @(
        'sql', 'server', 'firewall-rule', 'create',
        '--resource-group',   $ResourceGroup,
        '--server',           $SqlServerName,
        '--name',             $RuleName,
        '--start-ip-address', $Ip,
        '--end-ip-address',   $Ip
    ) | Out-Null

    Write-Done "Firewall rule '$RuleName' created for $Ip"
    Write-Host "     Both ara_legacy and ara_new are now accessible from $Ip" -ForegroundColor DarkGray
}

function Remove-FirewallIp([string] $Ip, [string] $RuleName) {
    Write-Step "Removing firewall rule for IP: $Ip"

    if ([string]::IsNullOrWhiteSpace($RuleName)) {
        [string] $rulesJson = az sql server firewall-rule list `
            --resource-group $ResourceGroup `
            --server         $SqlServerName 2>$null

        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($rulesJson)) {
            throw "Could not list firewall rules on '$SqlServerName'."
        }

        $rules = $rulesJson | ConvertFrom-Json
        $match = $rules | Where-Object { $_.startIpAddress -eq $Ip }

        if (-not $match) {
            Write-Warn "No firewall rule found with startIpAddress = $Ip. No changes made."
            return
        }

        $matchArray = @($match)
        if ($matchArray.Count -gt 1) {
            Write-Warn "Multiple firewall rules match $Ip. Removing the first match: '$($matchArray[0].name)'."
            Write-Warn 'Re-run with -FirewallRuleName to target a specific rule.'
        }

        $RuleName = $matchArray[0].name
    }

    [string] $existingJson = az sql server firewall-rule show `
        --resource-group $ResourceGroup `
        --server         $SqlServerName `
        --name           $RuleName 2>$null

    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($existingJson)) {
        Write-Warn "Firewall rule '$RuleName' not found on '$SqlServerName'. No changes made."
        return
    }

    Invoke-Az @(
        'sql', 'server', 'firewall-rule', 'delete',
        '--resource-group', $ResourceGroup,
        '--server',         $SqlServerName,
        '--name',           $RuleName,
        '--yes'
    ) | Out-Null

    Write-Done "Firewall rule '$RuleName' removed. $Ip can no longer access the server."
}

# ── Entry point ─────────────────────────────────────────────────────────────────

try {
    Write-Host ''
    Write-Host "  ARA Personal Database Manager  |  Action: $Action" -ForegroundColor White
    Write-Separator

    Assert-Prerequisites
    Set-ActiveSubscription

    # Always ensure this machine's current IP is open on the firewall, regardless of
    # which action is being run. Skipped when the server does not yet exist (Provision
    # will call Confirm-CurrentMachineFirewallRule after creating the server).
    [string] $serverCheck = az sql server show `
        --resource-group $ResourceGroup `
        --name           $SqlServerName 2>$null

    if ($serverCheck) {
        Confirm-CurrentMachineFirewallRule
    }

    switch ($Action) {

        'Provision' {
            Assert-SqlServerModule

            # Resolve SQL server admin secret (only needed when the server does not exist yet).
            [string] $serverExists = az sql server show `
                --resource-group $ResourceGroup `
                --name           $SqlServerName 2>$null

            [string] $plainAdminSecret = ''
            if (-not $serverExists) {
                if ($SqlAdminPassword) {
                    $plainAdminSecret = ConvertTo-PlainText $SqlAdminPassword
                } else {
                    Write-Host "`n  SQL server does not exist. Enter a password for the SQL admin account '$SqlAdminLogin'." -ForegroundColor Yellow
                    Write-Host '  This is a break-glass account — use Azure AD or the app SQL login for connections.' -ForegroundColor DarkGray
                    $prompted = Read-Host -Prompt '  SQL Admin Password' -AsSecureString
                    $plainAdminSecret = ConvertTo-PlainText $prompted
                }
            }

            # Resolve application SQL login name and secret.
            if ([string]::IsNullOrWhiteSpace($DbUserLogin)) {
                Write-Host ''
                $DbUserLogin = Read-Host -Prompt '  Application SQL login name (e.g. araapp)'
            }

            [string] $plainUserSecret = ''
            if ($DbUserPassword) {
                $plainUserSecret = ConvertTo-PlainText $DbUserPassword
            } else {
                Write-Host "  Enter a password for the SQL login '$DbUserLogin'." -ForegroundColor Yellow
                $promptedDb = Read-Host -Prompt '  SQL Login Password' -AsSecureString
                $plainUserSecret = ConvertTo-PlainText $promptedDb
            }

            Confirm-ResourceGroup
            Confirm-SqlServer     $plainAdminSecret
            Set-SqlAzureAdAdmin
            Confirm-Database      $LegacyDatabase
            Confirm-Database      $NewDatabase
            Set-InitialFirewallRules
            New-SqlLoginAndUsers  $DbUserLogin $plainUserSecret
            Show-ConnectionStrings $DbUserLogin
            Show-CostGuidance

            Write-Host '  Provisioning complete.' -ForegroundColor Green
            Write-Host "  Next step: paste a connection string above into appsettings.Development.json`n" -ForegroundColor DarkGray
        }

        'Remove' {
            Write-Host ''
            Write-Warn "This will permanently delete '$LegacyDatabase', '$NewDatabase', and '$SqlServerName'."
            Write-Warn 'All data will be lost. The resource group is left intact.'
            Write-Host ''
            [string] $confirm = Read-Host "  Type 'yes' to confirm"

            if ($confirm -ne 'yes') {
                Write-Host "`n  Aborted. No changes made.`n" -ForegroundColor DarkGray
                exit 0
            }

            Remove-SqlDatabase $LegacyDatabase
            Remove-SqlDatabase $NewDatabase
            Remove-SqlServer

            Write-Host "`n  All resources deleted. Run with -Action Provision to restore.`n" -ForegroundColor Green
        }

        'AddFirewallIp' {
            Assert-IpAddress $IpAddress
            Add-FirewallIp $IpAddress $FirewallRuleName
        }

        'RemoveFirewallIp' {
            Assert-IpAddress $IpAddress
            Remove-FirewallIp $IpAddress $FirewallRuleName
        }
    }
} catch {
    Write-Host "`n  ✗  Error: $_`n" -ForegroundColor Red
    exit 1
}
