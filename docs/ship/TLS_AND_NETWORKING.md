# ARA on-prem — TLS + networking

Network and TLS reference for the ARA on-prem deployment. Two audiences:

- **Network / security team** — gets handed the **outbound allowlist** (§3) and the **inbound rules** (§4) and translates them into firewall changes.
- **Operator / installer** — uses the **TLS / cert binding** (§2) when standing up a new server or rotating a cert, and the same allowlist as a pre-install gate (cross-referenced from `docs/ship/ON_PREM_DEPLOYMENT.md` §2).

This is the SHIP_PLAN Item 8d deliverable. Decisions D7 and D10 of `docs/ship/ON_PREM_PIVOT_PLAN.md` are the source of truth for the architectural choices summarized below — the docs here are the operator-facing translation.

**Contents:**

- [1. Summary](#1-summary)
- [2. TLS — cert binding on IIS](#2-tls--cert-binding-on-iis)
- [3. Outbound allowlist](#3-outbound-allowlist)
- [4. Inbound rules](#4-inbound-rules)

The doc covers both **Windows Server 2019** and **Windows Server 2022**. Where behavior differs it is called out; otherwise treat them as interchangeable.

---

## 1. Summary

The on-prem ARA app runs on a single Windows Server box (`agxmthrisweb01.hii-tsd.com` per D10) that is:

- **Inbound:** reachable on `:443` from the internal HII network only. **Not** reachable from the public internet (D10).
- **Outbound:** restricted to a small allowlist (D10). Each entry in §3 has an explicit `host:port` + protocol + rationale so the network team can file precise firewall rules without guessing.
- **TLS termination:** at IIS, using a cert from the internal CA bound to the site (D7). The app does not handle TLS itself — Kestrel serves plaintext to IIS over the in-process `AspNetCoreModuleV2` handoff, and IIS terminates 443 with the bound cert.
- **No reverse proxy** in front of IIS. `ara.hii-tsd.com` (prod) and `aradev.hii-tsd.com` (dev / test) DNS records resolve directly to the server's internal IP.

The app does NOT use mutual TLS, client certificates, or SNI fronting. Bindings are by hostname → cert thumbprint.

---

## 2. TLS — cert binding on IIS

### 2.1 Prerequisites

- The cert must already be imported to `LocalMachine\My` with its private key. The import procedure (request from internal CA → `Import-PfxCertificate` → capture thumbprint) is in `docs/ship/ON_PREM_DEPLOYMENT.md` §1.4.
- The IIS site (default name `ARA`) and the HTTPS:443 binding (default hostname from `-SiteHostname`) are created by `scripts/Install-AraOnPremises.ps1`. **You normally bind the cert by running the installer**, not by hand. The PowerShell + UI paths below are for manual cert rotation, troubleshooting, or operating without re-running the installer.

### 2.2 Bind via PowerShell (preferred)

This matches what the installer's `Set-IisSite` function does internally. It pins the cert by **SHA-1 thumbprint**, not by CN, so there is no ambiguity if more than one cert in the store could match the hostname.

```powershell
Import-Module WebAdministration

$siteName    = "ARA"                                       # or whatever -IisSiteName was used
$hostname    = "ara.hii-tsd.com"                           # or aradev.hii-tsd.com for dev / test
$thumbprint  = "<40-char-thumbprint-from-LocalMachine\My>" # see ON_PREM_DEPLOYMENT.md §1.4

# Make sure an HTTPS:443 binding exists for the hostname:
$existing = Get-WebBinding -Name $siteName -Protocol https -ErrorAction SilentlyContinue
if (-not $existing) {
    New-WebBinding -Name $siteName -Protocol https `
        -Port 443 -HostHeader $hostname -SslFlags 1 | Out-Null
}

# Bind the cert. Removing any existing IIS:\SslBindings entry first prevents
# "binding already exists" errors when rotating to a new cert.
$sslPath = "IIS:\SslBindings\!443!$hostname"
if (Test-Path $sslPath) { Remove-Item $sslPath -Force }
Get-Item "Cert:\LocalMachine\My\$thumbprint" |
    New-Item -Path $sslPath -SslFlags 1 | Out-Null
```

`-SslFlags 1` enables **SNI** so multiple HTTPS sites can share `:443` on the same IP. ARA only needs a single hostname per server today, but using SNI from the start avoids surprises if a second site is ever added.

**Verify:**

```powershell
Get-WebBinding -Name $siteName -Protocol https |
    Select-Object protocol, bindingInformation, certificateHash
# Expect bindingInformation = "*:443:<hostname>"
# Expect certificateHash    = your thumbprint, uppercase

# Round-trip check (no cert validation since we don't trust the internal CA chain by default):
iwr "https://$hostname/health/live" -SkipCertificateCheck
# Expect 200, empty body.
```

### 2.3 Bind via IIS Manager (UI fallback)

For operators who prefer the GUI or are troubleshooting from a remote desktop session:

1. Open **Internet Information Services (IIS) Manager** (`inetmgr.exe`).
2. In the Connections pane, expand the server → **Sites** → select the **ARA** site.
3. In the Actions pane (right side), click **Bindings…**.
4. If an `https` binding for the hostname already exists: select it and click **Edit…**. Otherwise click **Add…** and choose Type `https`, leave IP set to `All Unassigned`, Port `443`, Host name = the environment's hostname, check **Require Server Name Indication**.
5. Under **SSL certificate**, pick the cert by friendly name or thumbprint. Click **OK**.
6. Click **Close**.

**Verify** the same way as §2.2 (`Get-WebBinding` + `iwr`).

### 2.4 Renewal

Renewal is the same operation as initial bind, just with the new cert's thumbprint. The full sequence (request → import → capture → re-bind) is in `ON_PREM_DEPLOYMENT.md` §1.5. The install script's `-CertThumbprint <new-thumbprint>` is the recommended path because it also re-validates everything else (cert format, presence, private key, expiry) before touching the binding.

If `LocalMachine\My` ends up with both old and new certs co-resident during a renewal, the install script's thumbprint pinning binds the one you point at — no risk of selecting the wrong cert. Once the new binding is verified working, remove the expired cert: `Remove-Item Cert:\LocalMachine\My\<old-thumbprint>`.

---

## 3. Outbound allowlist

The on-prem server's outbound traffic must be restricted to the entries below. Each row is mandatory unless the **Conditional** column says otherwise.

| Destination | Port / Protocol | Mandatory? | Used for |
|-------------|-----------------|------------|----------|
| `hii-test.oktapreview.com` | `tcp/443` (HTTPS) | yes if dev / test cert hostname is served from this server | OAuth / OIDC against the Okta test tenant: token validation, JWKS fetch, OIDC discovery |
| `hii.okta-gov.com` | `tcp/443` (HTTPS) | yes if prod cert hostname is served from this server | OAuth / OIDC against the Okta production tenant (GCC High) |
| `<sqlmi-host>.database.windows.net` | `tcp/1433` | **always** | Azure SQL Managed Instance — primary database connection (login + every query) |
| `<sqlmi-host>.database.windows.net` | `tcp/11000-11999` | **always** (when MI redirect connection mode is in use, which is the default) | Azure SQL MI redirect connection range. After the initial 1433 handshake, the gateway redirects clients to a worker on a port in this range. Without it, every query hangs at the Azure side |
| `<region>.in.applicationinsights.azure.com` | `tcp/443` (HTTPS) | yes if `-AppInsightsConnectionString` is configured | Application Insights telemetry ingestion. Failure here is silent — telemetry just does not appear in Azure Monitor |
| `<region>.livediagnostics.monitor.azure.com` | `tcp/443` (HTTPS) | yes if Live Metrics are wanted in the Azure portal | App Insights Live Metrics stream (the real-time dashboard in the AI blade). Optional — no traces are lost if blocked |
| `smtp.office365.com` | `tcp/587` (SMTP STARTTLS) | yes if `-SmtpHost` is configured for commercial M365 | M365 SMTP relay (commercial tenant). Outbound email for ARA workflow notifications |
| `smtp.office365.us` | `tcp/587` (SMTP STARTTLS) | yes if `-SmtpHost` is configured for GCC High | M365 SMTP relay (GCC High tenant). Same purpose, different cloud |

**Notes for the network team:**

- **Azure SQL MI redirect range (`11000-11999`)** is the load-bearing one that's easy to miss. The 1433 connection alone passes `Test-NetConnection` because the initial TLS / login handshake completes — but every actual query hangs because the gateway redirects to a worker port in the 11000-11999 range (this is documented Azure SQL MI behavior). If users report "the app loads but never returns data," this is the rule that's almost certainly missing. To force proxy mode (1433 only) the connection string would need `Connection Timeout=30;Encrypt=True;TrustServerCertificate=False;Connect Retry Count=3;` plus the MI must be configured for proxy mode by the DBA — that's a workaround, not a recommendation.
- **App Insights region** is the AI workspace's region (e.g. `westus2-2.in.applicationinsights.azure.com`). Confirm the actual host with a `nslookup` against the connection string's `IngestionEndpoint` value, or get it from the AI blade in the portal.
- **Okta hostnames** are tenant-specific. The `hii-test.oktapreview.com` test tenant and `hii.okta-gov.com` prod tenant are HII's. If a different Okta tenant is ever introduced, that hostname needs to be added to the allowlist.
- **M365 SMTP relay does NOT require authentication from this server** (D6). Mail flow works because the application server's IP is on the relay's allowlist (managed by the M365 / Exchange admin). The SMTP rule on this side just opens the TCP path; the relay-side allowlist is the auth gate. If `-SmtpHost` is unset the app falls back to `LoggingEmailService` (writes to the `EmailLog` table only) and this row can be omitted.
- **No public DNS for the server itself** (D10) — operators reach `ara.hii-tsd.com` and `aradev.hii-tsd.com` via internal DNS only. Outbound is HTTPS / SQL only, not arbitrary; no general internet egress is needed.

**Verification commands:** see `docs/ship/ON_PREM_DEPLOYMENT.md` §2.1 (Item 8e pre-install gate). Each rule should produce `TcpTestSucceeded : True` from `Test-NetConnection` on the on-prem box. Run them before every install.

**WS 2019 vs WS 2022:** identical. The outbound endpoints, ports, and protocols don't depend on the OS version.

---

## 4. Inbound rules

| Source | Port / Protocol | Action | Notes |
|--------|-----------------|--------|-------|
| Internal HII network | `tcp/443` (HTTPS) | **Allow** | Primary application traffic. SPA + API + health probes all served on this binding |
| Public internet | `tcp/443` | **Deny** | Per D10 — the server is not internet-reachable. No public DNS record points at it |
| Internal HII network | `tcp/80` (HTTP) | **Optional** — see below | Either redirect to 443 or close entirely |
| Anywhere | `tcp/3389` (RDP) | Per ops policy | Not in scope here; manage like any other Windows Server box |

### 4.1 HTTP:80 — redirect or close

The ARA app does not serve plaintext HTTP. Two acceptable patterns for `:80`:

- **Close entirely** — block at the firewall, no IIS binding on port 80. Simplest. Users / scripts that hit `http://<host>/` get a connection refused, then learn to use HTTPS.
- **Redirect to HTTPS** — bind port 80 in IIS with the URL Rewrite module's `HTTP to HTTPS` redirect rule. Friendlier UX (browsers auto-upgrade), but requires the URL Rewrite module to be installed (not part of the ARA install script — operator adds it manually if this pattern is chosen).

**If you go with close-entirely** (recommended for simplicity), no extra config is needed beyond the firewall rule.

**If you go with redirect**, install the URL Rewrite module from <https://www.iis.net/downloads/microsoft/url-rewrite>, add an HTTP:80 binding to the ARA site (no SNI, no host header), and add a redirect rule via `web.config` or IIS Manager:

```xml
<rewrite>
  <rules>
    <rule name="HTTP to HTTPS" stopProcessing="true">
      <match url="(.*)" />
      <conditions>
        <add input="{HTTPS}" pattern="off" ignoreCase="true" />
      </conditions>
      <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" redirectType="Permanent" />
    </rule>
  </rules>
</rewrite>
```

The on-prem install script does NOT configure either path automatically — pick whichever fits your ops policy and apply it manually.

### 4.2 No inbound from the public internet

Per D10, the server has no public IP and no public DNS record. The cert is issued by the internal CA, which means external browsers wouldn't trust it anyway. This is intentional — ARA is an internal workflow tool and there is no use case for external access.

If a future requirement to expose the app externally appears, that's a meaningful architectural change: either a reverse proxy (F5 / NetScaler / Azure Front Door) terminating a public cert in front of the on-prem server, or a Container Apps / App Service hosting model. Both options are out of scope for this doc.

**WS 2019 vs WS 2022:** identical. Inbound rules don't depend on the OS version.
