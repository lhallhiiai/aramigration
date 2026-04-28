using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace ARA.Infrastructure.HealthChecks;

/// <summary>
/// Readiness probe for the configured Okta authorization server's OIDC discovery
/// document. When <c>Okta:Issuer</c> is unset, the check reports
/// <see cref="HealthStatus.Degraded"/> — that configuration is the dev-auth
/// bypass path (see <c>DevAuthenticationHandler</c>) and must not block local
/// startup. In any environment where Okta is the configured authentication
/// scheme, the JWT bearer middleware cannot validate tokens unless this
/// document is reachable, so an outage here will reject every signed-in
/// request.
/// </summary>
public sealed class OktaMetadataHealthCheck : IHealthCheck
{
    /// <summary>Logical name of the typed <see cref="HttpClient"/> used by this check.</summary>
    public const string HttpClientName = "OktaMetadataHealthCheck";

    private readonly IConfiguration _configuration;
    private readonly IHttpClientFactory _httpClientFactory;

    /// <summary>Initializes a new instance of <see cref="OktaMetadataHealthCheck"/>.</summary>
    public OktaMetadataHealthCheck(
        IConfiguration configuration,
        IHttpClientFactory httpClientFactory)
    {
        _configuration = configuration;
        _httpClientFactory = httpClientFactory;
    }

    /// <inheritdoc/>
    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        string? issuer = _configuration["Okta:Issuer"];
        if (string.IsNullOrWhiteSpace(issuer))
        {
            return HealthCheckResult.Degraded(
                "Okta:Issuer is not configured. Dev authentication bypass is in effect; production must set this.");
        }

        string discoveryUri = $"{issuer.TrimEnd('/')}/.well-known/openid-configuration";

        try
        {
            HttpClient client = _httpClientFactory.CreateClient(HttpClientName);
            using HttpResponseMessage response = await client.GetAsync(
                discoveryUri,
                HttpCompletionOption.ResponseHeadersRead,
                cancellationToken);

            return response.IsSuccessStatusCode
                ? HealthCheckResult.Healthy($"Okta discovery '{discoveryUri}' reachable ({(int)response.StatusCode}).")
                : HealthCheckResult.Unhealthy(
                    $"Okta discovery '{discoveryUri}' returned {(int)response.StatusCode} {response.ReasonPhrase}.");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy($"Okta discovery '{discoveryUri}' unreachable.", ex);
        }
    }
}
