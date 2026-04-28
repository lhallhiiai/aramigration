using System.Security.Claims;
using ARA.Application.Common;
using ARA.Domain.Entities;

namespace ARA.Application.Users;

/// <summary>
/// Provisions local user records for authenticated Okta identities.
/// Supports two paths: just-in-time creation from token claims on first sign-in,
/// and admin-driven onboarding when a row must exist before any sign-in
/// (e.g. background processes that authenticate without going through the SPA).
/// </summary>
public interface IUserProvisioningService
{
    /// <summary>
    /// Ensures a local user row exists for the authenticated principal.
    /// Reads the Okta <c>sub</c> claim (with fallback to <see cref="ClaimTypes.NameIdentifier"/>),
    /// email, name, and given/family-name claims. No-op when a row already exists.
    /// </summary>
    /// <param name="principal">The authenticated principal carrying the token claims.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>
    /// The user row that ends up in the database (existing or newly created),
    /// or a failure when required claims are missing.
    /// </returns>
    Task<Result<User>> ProvisionFromClaimsAsync(
        ClaimsPrincipal principal,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Ensures a local user row exists for the supplied identity, bypassing the claims path.
    /// Used by the admin-onboarding endpoint to seed users before first sign-in.
    /// </summary>
    /// <param name="externalUserId">The Okta subject identifier (sub) for the user.</param>
    /// <param name="email">The user's email address.</param>
    /// <param name="displayName">The user's full display name.</param>
    /// <param name="firstName">The user's first name, if available.</param>
    /// <param name="lastName">The user's last name, if available.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>The user row that ends up in the database (existing or newly created).</returns>
    Task<Result<User>> ProvisionAsync(
        string externalUserId,
        string email,
        string displayName,
        string? firstName,
        string? lastName,
        CancellationToken cancellationToken = default);
}
