using ARA.Application.Common;
using ARA.Application.Users;
using ARA.Domain.Entities;

namespace ARA.Api.Middleware;

/// <summary>
/// Just-in-time provisioning middleware. Runs after authentication has succeeded
/// and before authorization. For every authenticated request it ensures a local
/// <see cref="ARA.Domain.Entities.User"/> row exists for the caller's Okta
/// <c>sub</c> claim. Idempotent: when the row already exists this is a single
/// SELECT and falls through.
///
/// On hard failures (missing required claims, database unreachable, etc.) the
/// middleware short-circuits with HTTP 500 and a Problem Details payload —
/// matching the project-wide error contract from <c>ProblemDetailsMiddleware</c>.
///
/// <para>
/// GCC High note: on <c>hii.okta-gov.com</c>, <c>credentials.provider.*</c>
/// filter paths are disabled. This middleware does not query the Okta directory;
/// it only consumes claims already present on the authenticated principal, so
/// the GCC High quirk has no effect here. Any future directory queries (e.g.
/// for an admin "search Okta users" endpoint) must scope by app integration
/// rather than provider filter.
/// </para>
/// </summary>
public sealed class JitUserProvisioningMiddleware
{
    private readonly RequestDelegate _next;

    /// <summary>Initializes a new instance of <see cref="JitUserProvisioningMiddleware"/>.</summary>
    public JitUserProvisioningMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    /// <summary>Provisions the caller (if needed) then invokes the next middleware.</summary>
    public async Task InvokeAsync(
        HttpContext context,
        IUserProvisioningService provisioningService,
        ILogger<JitUserProvisioningMiddleware> logger)
    {
        if (context.User?.Identity?.IsAuthenticated != true)
        {
            await _next(context);
            return;
        }

        Result<User> result = await provisioningService.ProvisionFromClaimsAsync(
            context.User,
            context.RequestAborted);

        if (result.IsFailure)
        {
            logger.LogError(
                "JIT user provisioning failed: {Error}. Path={Path}",
                result.Error,
                context.Request.Path);

            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            context.Response.ContentType = "application/problem+json";
            await context.Response.WriteAsync(
                """{"type":"about:blank","title":"User provisioning failed","status":500,"detail":"The authenticated request could not be associated with a local user record. See server logs for details."}""");
            return;
        }

        await _next(context);
    }
}
