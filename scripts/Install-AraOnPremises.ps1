<#
.SYNOPSIS
    Installs the ARA application on a Windows Server box (2019 or 2022) under IIS.

.DESCRIPTION
    On-prem installer for the ARA app. Implements SHIP_PLAN Item 8b. Operator runs this
    by hand on the target server (no MSI per D8 of the on-prem pivot). The script:

      1. Validates we are on Windows Server 2019 or 2022 (D9).
      2. Checks IIS, the ASP.NET Core Hosting Bundle, and the WebAdministration module.
      3. Resolves the publish bundle (zip OR folder) and stages it under `-InstallPath`.
      4. Generates `appsettings.Production.json` from the tracked
         `appsettings.Production.json.example` template by injecting the supplied values
         (D4 = NTFS-protected JSON, no Key Vault).
      5. Sets restrictive NTFS ACLs on `appsettings.Production.json`: read for the IIS
         app pool identity + local Administrators only.
      6. Creates / updates the IIS app pool + site, binds HTTPS:443 to the cert the
         operator selects from `LocalMachine\My`.

    Idempotent: re-running with the same parameters produces no destructive changes.
    Use `-Force` to overwrite an existing `appsettings.Production.json`. The IIS site
    is updated in place when it already exists.

    SMTP is optional (D6). If `-SmtpHost` is empty the app falls back to
    `LoggingEmailService` and just records emails to the `EmailLog` table.

.PARAMETER PublishBundlePath
    Path to either a `.zip` of the `dotnet publish` output or the unzipped folder.

.PARAMETER InstallPath
    Where to stage the publish bundle on the server. Defaults to
    `C:\inetpub\sites\<IisSiteName>`.

.PARAMETER IisSiteName
    Name of the IIS site (also used as the app pool name and to derive a default
    install path). Defaults to `ARA`.

.PARAMETER SiteHostname
    Hostname for the IIS HTTPS binding. Examples: `ara.hii-tsd.com` (prod cert),
    `aradev.hii-tsd.com` (dev / test cert). Required.

.PARAMETER CertSubject
    Subject (CN) of the cert in `LocalMachine\My` to bind HTTPS:443 to. The script
    locates the matching cert and uses its thumbprint. Required.

.PARAMETER AppPoolIdentity
    Optional. If empty, the IIS-virtual `IIS AppPool\<IisSiteName>` identity is used
    (no password needed). If set, the script switches the app pool to a SpecificUser
    identity and prompts for the password securely.

.PARAMETER SqlConnectionString
    SQL Authentication connection string per D3 (no AAD). Example:
    `Server=tcp:<host>,1433;Database=ara_new;User ID=<u>;Password=<p>;Encrypt=True;`.
    The script does not validate the connection — that's the operator's smoke step.

.PARAMETER OktaIssuer
    Okta authorization-server issuer URL. Example test:
    `https://hii-test.oktapreview.com/oauth2/default`. Production tenant differs.

.PARAMETER OktaAudience
    Okta token audience. Conventionally `api://default`.

.PARAMETER AppInsightsConnectionString
    Azure Monitor / Application Insights ingestion connection string. Required if
    telemetry is wanted; pass empty to disable (the SDK no-ops on empty string).

.PARAMETER SmtpHost
    SMTP relay host. Empty / not set => `LoggingEmailService` fallback (D6 laptop-dev
    path). Any non-empty value => `M365SmtpEmailService` is selected at startup and
    the remaining `Smtp*` parameters are required.

.PARAMETER SmtpPort
    SMTP relay port. No default — operator picks per relay (commonly 25 or 587).

.PARAMETER SmtpSecureSocketOptions
    MailKit `SecureSocketOptions` enum as string. Allowed values: `None`, `Auto`,
    `SslOnConnect`, `StartTls`, `StartTlsWhenAvailable`. Defaults to `Auto`.
    Validated at app startup (`InfrastructureServiceExtensions.ParseSecureSocketOptions`).

.PARAMETER SmtpFromAddress
    Envelope From-address. Per CLAUDE.md, conventionally `ara@hii-tsd.com`.

.PARAMETER AllowedOrigin
    CORS origin for the SPA. Example: `https://ara.hii-tsd.com`. Required so the
    frontend can call the API cross-origin.

.PARAMETER Force
    Overwrites an existing `appsettings.Production.json` without prompting.

.EXAMPLE
    .\Install-AraOnPremises.ps1 -PublishBundlePath C:\Staging\ARA-Publish.zip `
        -SiteHostname ara.hii-tsd.com `
        -CertSubject ara.hii-tsd.com `
        -SqlConnectionString "Server=tcp:sql-mi-host,1433;..." `
        -OktaIssuer "https://hii-test.oktapreview.com/oauth2/default" `
        -OktaAudience "api://default" `
        -AppInsightsConnectionString "InstrumentationKey=..." `
        -AllowedOrigin "https://ara.hii-tsd.com" `
        -SmtpHost "smtp.relay.internal" -SmtpPort 25 -SmtpFromAddress "ara@hii-tsd.com"

.NOTES
    Targets PowerShell 5.1 (ships in-box on WS 2019 + WS 2022) and PS 7+. Uses only
    the `WebAdministration` module + standard cmdlets — no third-party dependencies.

    WS 2019 vs WS 2022 differences encountered today:
      - Both ship PS 5.1, both expose the `WebAdministration` module the same way.
      - Both use `Install-WindowsFeature` for IIS roles; cmdlet syntax is identical.
      - The .NET 10 ASP.NET Core Hosting Bundle install is identical on both.
    If a future divergence appears, branch on `$serverVersion` (set in `Test-OsVersion`).
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string] $PublishBundlePath,
    [string] $InstallPath,
    [string] $IisSiteName = "ARA",

    [Parameter(Mandatory)] [string] $SiteHostname,
    [Parameter(Mandatory)] [string] $CertSubject,
    [string] $AppPoolIdentity,

    [Parameter(Mandatory)] [string] $SqlConnectionString,
    [Parameter(Mandatory)] [string] $OktaIssuer,
    [string] $OktaAudience = "api://default",
    [string] $AppInsightsConnectionString = "",
    [Parameter(Mandatory)] [string] $AllowedOrigin,

    [string] $SmtpHost = "",
    [int] $SmtpPort = 0,
    [ValidateSet("None", "Auto", "SslOnConnect", "StartTls", "StartTlsWhenAvailable")]
    [string] $SmtpSecureSocketOptions = "Auto",
    [string] $SmtpFromAddress = "",

    [switch] $Force
)

$ErrorActionPreference = "Stop"

if (-not $InstallPath) {
    $InstallPath = Join-Path "C:\inetpub\sites" $IisSiteName
}

#region Helpers
function Test-OsVersion {
    $os = Get-CimInstance Win32_OperatingSystem
    $caption = $os.Caption
    if ($caption -notmatch "Windows Server 201[9]|Windows Server 2022") {
        throw "This installer targets Windows Server 2019 or Windows Server 2022. Detected: '$caption'."
    }
    Write-Verbose "Detected OS: $caption"
    return $caption
}

function Test-Prerequisites {
    # IIS — WebAdministration is the gate.
    if (-not (Get-Module -ListAvailable -Name WebAdministration)) {
        throw "WebAdministration module not found. Install IIS first: " +
            "Install-WindowsFeature -Name Web-Server, Web-Mgmt-Console, Web-Asp-Net45 -IncludeManagementTools"
    }
    Import-Module WebAdministration -ErrorAction Stop

    # ASP.NET Core Hosting Bundle for .NET 10 (the AspNetCoreModuleV2 native module)
    $aspNetModulePath = "$env:SystemRoot\System32\inetsrv\aspnetcorev2.dll"
    if (-not (Test-Path $aspNetModulePath)) {
        throw "ASP.NET Core Hosting Bundle not detected ($aspNetModulePath missing). " +
            "Download the .NET 10 Hosting Bundle from https://dotnet.microsoft.com/download/dotnet/10.0 and run it."
    }

    # .NET 10 runtime — separate check; AspNetCoreModuleV2 needs a matching runtime.
    $dotnetVersions = @()
    $dotnetExe = "$env:ProgramFiles\dotnet\dotnet.exe"
    if (Test-Path $dotnetExe) {
        $dotnetVersions = & $dotnetExe --list-runtimes 2>$null |
            Select-String -Pattern "Microsoft.AspNetCore.App 10\." |
            ForEach-Object { $_.Line }
    }
    if (-not $dotnetVersions) {
        throw "ASP.NET Core 10.x runtime not found on PATH. Confirm the Hosting Bundle install succeeded; " +
            "expected `$env:ProgramFiles\dotnet\dotnet.exe --list-runtimes` to list 'Microsoft.AspNetCore.App 10.x'."
    }
}

function Resolve-PublishBundle {
    param([string] $Path)

    if (-not (Test-Path $Path)) {
        throw "PublishBundlePath '$Path' does not exist."
    }

    $item = Get-Item $Path
    if ($item.PSIsContainer) {
        return $item.FullName
    }

    if ($item.Extension -ne ".zip") {
        throw "PublishBundlePath '$Path' must be a folder or a .zip file."
    }

    $extractTo = Join-Path $env:TEMP ("ara-publish-" + [guid]::NewGuid())
    New-Item -ItemType Directory -Path $extractTo | Out-Null
    Expand-Archive -Path $item.FullName -DestinationPath $extractTo -Force
    return $extractTo
}

function Sync-InstallPath {
    param([string] $SourceFolder, [string] $TargetFolder)

    if (-not (Test-Path $TargetFolder)) {
        New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
    }

    # robocopy returns non-zero exit codes for "files copied" — that is success here.
    & robocopy $SourceFolder $TargetFolder /MIR /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) {
        throw "robocopy failed with exit code $LASTEXITCODE while staging '$SourceFolder' -> '$TargetFolder'."
    }
}

function Write-AppSettingsProduction {
    param(
        [string] $TemplatePath,
        [string] $TargetPath,
        [bool]   $ForceOverwrite
    )

    if (-not (Test-Path $TemplatePath)) {
        throw "Template not found: '$TemplatePath'. Expected appsettings.Production.json.example in the publish bundle."
    }

    if ((Test-Path $TargetPath) -and -not $ForceOverwrite) {
        throw "'$TargetPath' already exists. Re-run with -Force to overwrite, or delete the file first."
    }

    $template = Get-Content -Raw -Path $TemplatePath
    $config = $template | ConvertFrom-Json

    $config.AllowedOrigins = @($AllowedOrigin)
    $config.Okta.Issuer = $OktaIssuer
    $config.Okta.Audience = $OktaAudience
    $config.ConnectionStrings.AraDatabase = $SqlConnectionString
    $config.ApplicationInsights.ConnectionString = $AppInsightsConnectionString
    $config.Email.FromAddress = $SmtpFromAddress
    $config.Email.Smtp.Host = $SmtpHost
    $config.Email.Smtp.Port = $SmtpPort
    $config.Email.Smtp.SecureSocketOptions = $SmtpSecureSocketOptions

    $json = $config | ConvertTo-Json -Depth 10
    Set-Content -Path $TargetPath -Value $json -Encoding UTF8
    Write-Verbose "Wrote $TargetPath"
}

function Set-AppSettingsAcl {
    param(
        [string] $Path,
        [string] $ReadIdentity
    )

    $acl = Get-Acl -Path $Path
    $acl.SetAccessRuleProtection($true, $false)
    foreach ($rule in @($acl.Access)) {
        $acl.RemoveAccessRule($rule) | Out-Null
    }

    $allowAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "BUILTIN\Administrators", "FullControl", "Allow")
    $allowSystem = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "NT AUTHORITY\SYSTEM", "FullControl", "Allow")
    $allowAppPool = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $ReadIdentity, "Read", "Allow")

    $acl.AddAccessRule($allowAdmin)
    $acl.AddAccessRule($allowSystem)
    $acl.AddAccessRule($allowAppPool)

    Set-Acl -Path $Path -AclObject $acl
    Write-Verbose "ACLs locked down on $Path (Admins + SYSTEM + read for $ReadIdentity)"
}

function Set-IisAppPool {
    param(
        [string] $PoolName,
        [string] $Identity
    )

    if (-not (Test-Path "IIS:\AppPools\$PoolName")) {
        New-Item -Path "IIS:\AppPools\$PoolName" | Out-Null
    }

    Set-ItemProperty "IIS:\AppPools\$PoolName" -Name managedRuntimeVersion -Value ""
    Set-ItemProperty "IIS:\AppPools\$PoolName" -Name enable32BitAppOnWin64 -Value $false

    if ([string]::IsNullOrWhiteSpace($Identity)) {
        # Use the IIS-virtual ApplicationPoolIdentity (`IIS AppPool\<PoolName>`).
        Set-ItemProperty "IIS:\AppPools\$PoolName" `
            -Name processModel.identityType -Value ApplicationPoolIdentity
        return "IIS AppPool\$PoolName"
    }

    $secure = Read-Host "Password for app pool identity '$Identity'" -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        Set-ItemProperty "IIS:\AppPools\$PoolName" `
            -Name processModel.identityType -Value SpecificUser
        Set-ItemProperty "IIS:\AppPools\$PoolName" `
            -Name processModel.userName -Value $Identity
        Set-ItemProperty "IIS:\AppPools\$PoolName" `
            -Name processModel.password -Value $plain
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
    return $Identity
}

function Set-IisSite {
    param(
        [string] $SiteName,
        [string] $PhysicalPath,
        [string] $PoolName,
        [string] $Hostname,
        [string] $CertThumbprint
    )

    if (-not (Test-Path "IIS:\Sites\$SiteName")) {
        New-Website -Name $SiteName -PhysicalPath $PhysicalPath `
            -ApplicationPool $PoolName -HostHeader $Hostname `
            -Port 443 -Ssl -Force | Out-Null
    } else {
        Set-ItemProperty "IIS:\Sites\$SiteName" -Name physicalPath -Value $PhysicalPath
        Set-ItemProperty "IIS:\Sites\$SiteName" -Name applicationPool -Value $PoolName
    }

    # Bind 443 with the chosen cert. The IIS:\SslBindings provider is the
    # canonical way to pin a thumbprint to a binding on PS 5.1 + PS 7.
    $existingBinding = Get-WebBinding -Name $SiteName -Protocol https -ErrorAction SilentlyContinue
    if (-not $existingBinding) {
        New-WebBinding -Name $SiteName -Protocol https -Port 443 -HostHeader $Hostname `
            -SslFlags 1 | Out-Null
    }

    $sslBinding = "IIS:\SslBindings\!443!$Hostname"
    if (Test-Path $sslBinding) {
        Remove-Item $sslBinding -Force
    }
    Get-Item "Cert:\LocalMachine\My\$CertThumbprint" |
        New-Item -Path $sslBinding -SslFlags 1 | Out-Null
}

function Resolve-CertThumbprint {
    param([string] $Subject)

    $cert = Get-ChildItem -Path "Cert:\LocalMachine\My" |
        Where-Object { $_.Subject -match "CN=$([Regex]::Escape($Subject))(,|$)" } |
        Sort-Object NotAfter -Descending |
        Select-Object -First 1

    if (-not $cert) {
        throw "No certificate found in LocalMachine\My with CN matching '$Subject'. " +
            "Import the internal-CA cert first (see TLS_AND_NETWORKING.md)."
    }
    Write-Verbose "Selected cert thumbprint $($cert.Thumbprint), expires $($cert.NotAfter)"
    return $cert.Thumbprint
}

function Test-SmtpConfiguration {
    if ([string]::IsNullOrWhiteSpace($SmtpHost)) {
        Write-Verbose "SMTP not configured -> app will use LoggingEmailService."
        return
    }

    if ($SmtpPort -le 0) {
        throw "-SmtpHost was supplied but -SmtpPort is missing or non-positive. " +
            "Pass -SmtpPort (commonly 25 or 587)."
    }

    if ([string]::IsNullOrWhiteSpace($SmtpFromAddress)) {
        throw "-SmtpHost was supplied but -SmtpFromAddress is missing. " +
            "Pass -SmtpFromAddress (e.g. 'ara@hii-tsd.com')."
    }
}
#endregion

#region Main
$serverCaption = Test-OsVersion
Test-Prerequisites
Test-SmtpConfiguration

Write-Host "Installing ARA on $serverCaption" -ForegroundColor Cyan
Write-Host "  IisSiteName:    $IisSiteName"
Write-Host "  InstallPath:    $InstallPath"
Write-Host "  SiteHostname:   $SiteHostname"
Write-Host "  CertSubject:    $CertSubject"
Write-Host "  SmtpHost:       $(if ($SmtpHost) { $SmtpHost } else { '(unset; LoggingEmailService fallback)' })"

$bundleSource = Resolve-PublishBundle -Path $PublishBundlePath

if ($PSCmdlet.ShouldProcess($InstallPath, "Stage publish bundle")) {
    Sync-InstallPath -SourceFolder $bundleSource -TargetFolder $InstallPath
}

$templatePath = Join-Path $InstallPath "appsettings.Production.json.example"
$configPath = Join-Path $InstallPath "appsettings.Production.json"

if ($PSCmdlet.ShouldProcess($configPath, "Generate appsettings.Production.json")) {
    Write-AppSettingsProduction -TemplatePath $templatePath -TargetPath $configPath -ForceOverwrite:$Force
}

$thumbprint = Resolve-CertThumbprint -Subject $CertSubject

$resolvedIdentity = Set-IisAppPool -PoolName $IisSiteName -Identity $AppPoolIdentity

if ($PSCmdlet.ShouldProcess($configPath, "Restrict NTFS ACLs")) {
    Set-AppSettingsAcl -Path $configPath -ReadIdentity $resolvedIdentity
}

if ($PSCmdlet.ShouldProcess("IIS:\Sites\$IisSiteName", "Create or update site bound to https://$SiteHostname")) {
    Set-IisSite -SiteName $IisSiteName -PhysicalPath $InstallPath `
        -PoolName $IisSiteName -Hostname $SiteHostname -CertThumbprint $thumbprint
}

Write-Host ""
Write-Host "Install complete." -ForegroundColor Green
Write-Host "  Site:           IIS:\Sites\$IisSiteName"
Write-Host "  PhysicalPath:   $InstallPath"
Write-Host "  AppPool:        $IisSiteName (identity: $resolvedIdentity)"
Write-Host "  HTTPS binding:  https://${SiteHostname}:443 (cert thumbprint $thumbprint)"
Write-Host ""
Write-Host "Verify next:"
Write-Host "  iwr https://$SiteHostname/health/live  -SkipCertificateCheck   # expect 200, empty body"
Write-Host "  iwr https://$SiteHostname/health/ready -SkipCertificateCheck   # expect 200, JSON body"
#endregion
