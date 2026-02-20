using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using System.Security.Claims;
using System.Text.Encodings.Web;

namespace ARA.Api.Middleware;

/// <summary>
/// Development-only authentication handler that auto-authenticates all
/// requests with a fake developer identity. Activated only when running
/// in the Development environment with no AzureAd:TenantId configured.
/// Never registers itself in any other environment.
/// </summary>
public sealed class DevAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    /// <summary>
    /// The authentication scheme name used to register this handler.
    /// </summary>
    public const string SchemeName = "DevAuth";

    /// <inheritdoc />
    public DevAuthenticationHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder) : base(options, logger, encoder)
    {
    }

    /// <inheritdoc />
    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        Logger.LogWarning(
            "DevAuthenticationHandler is active. All requests are auto-authenticated. " +
            "This handler must never run in production.");

        Claim[] claims =
        [
            new Claim(ClaimTypes.NameIdentifier, "dev-user-00000000"),
            new Claim(ClaimTypes.Name, "Developer"),
            new Claim(ClaimTypes.Email, "dev@local.dev"),
        ];

        ClaimsIdentity identity = new(claims, SchemeName);
        ClaimsPrincipal principal = new(identity);
        AuthenticationTicket ticket = new(principal, SchemeName);

        return Task.FromResult(AuthenticateResult.Success(ticket));
    }
}
