using Azure;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace ARA.Infrastructure.HealthChecks;

/// <summary>
/// Readiness probe for the Azure Key Vault that backs the application's secret
/// configuration. When <c>KeyVaultUri</c> is unset (typical local-dev path,
/// see <c>docs/ship/LOCAL_DEV_SECRETS.md</c>), the check reports
/// <see cref="HealthStatus.Degraded"/> with an explanatory message rather than
/// failing — local dev does not require Key Vault. In production the Container
/// App's Managed Identity must be able to list secrets in the vault.
/// </summary>
public sealed class KeyVaultHealthCheck : IHealthCheck
{
    private readonly IConfiguration _configuration;

    /// <summary>Initializes a new instance of <see cref="KeyVaultHealthCheck"/>.</summary>
    public KeyVaultHealthCheck(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    /// <inheritdoc/>
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        string? keyVaultUri = _configuration["KeyVaultUri"];
        if (string.IsNullOrWhiteSpace(keyVaultUri))
        {
            return HealthCheckResult.Degraded(
                "KeyVaultUri is not configured. Local dev uses dotnet user-secrets (see docs/ship/LOCAL_DEV_SECRETS.md); production must set this.");
        }

        try
        {
            SecretClient client = new(new Uri(keyVaultUri), new DefaultAzureCredential());

            // Pull a single page of secret properties. This validates network
            // reachability AND that the calling identity has list permission,
            // without depending on a specific secret name being present.
            await foreach (Page<SecretProperties> page in client
                .GetPropertiesOfSecretsAsync(cancellationToken)
                .AsPages(pageSizeHint: 1)
                .WithCancellation(cancellationToken))
            {
                _ = page;
                return HealthCheckResult.Healthy($"KeyVault '{keyVaultUri}' reachable.");
            }

            // Empty vault still proves reachability + permission.
            return HealthCheckResult.Healthy($"KeyVault '{keyVaultUri}' reachable (no secrets present).");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy($"KeyVault '{keyVaultUri}' unreachable.", ex);
        }
    }
}

