using System.Security.Claims;
using ARA.Application.Common;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Users;

/// <summary>
/// Default implementation of <see cref="IUserProvisioningService"/>.
/// Provisioning is delegated to <see cref="IUserRepository.ProvisionAsync"/>,
/// which is idempotent on the <c>ExternalUserId</c> column.
/// </summary>
public sealed class UserProvisioningService : IUserProvisioningService
{
    private readonly IUserRepository _userRepository;
    private readonly ILogger<UserProvisioningService> _logger;

    /// <summary>Initializes a new instance of <see cref="UserProvisioningService"/>.</summary>
    public UserProvisioningService(
        IUserRepository userRepository,
        ILogger<UserProvisioningService> logger)
    {
        _userRepository = userRepository;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<Result<User>> ProvisionFromClaimsAsync(
        ClaimsPrincipal principal,
        CancellationToken cancellationToken = default)
    {
        // Okta sets "sub"; the JWT bearer middleware also maps it to NameIdentifier.
        // DevAuthenticationHandler only sets NameIdentifier. Read both for compatibility.
        // Using FindFirst(...)?.Value (BCL) instead of FindFirstValue (AspNetCore extension)
        // so this Application layer stays free of AspNetCore dependencies.
        string? externalUserId = principal.FindFirst("sub")?.Value
            ?? principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrWhiteSpace(externalUserId))
        {
            return Result<User>.Failure("Authenticated principal has no sub or NameIdentifier claim.");
        }

        string? email = principal.FindFirst(ClaimTypes.Email)?.Value
            ?? principal.FindFirst("email")?.Value;
        if (string.IsNullOrWhiteSpace(email))
        {
            return Result<User>.Failure(
                $"Authenticated principal '{externalUserId}' has no email claim. The Okta token must include the 'email' scope.");
        }

        string firstName = principal.FindFirst(ClaimTypes.GivenName)?.Value
            ?? principal.FindFirst("given_name")?.Value
            ?? string.Empty;
        string lastName = principal.FindFirst(ClaimTypes.Surname)?.Value
            ?? principal.FindFirst("family_name")?.Value
            ?? string.Empty;

        // Display name: prefer the "name" claim, fall back to "given + family",
        // fall back to the email (which we know is non-empty by this point).
        string displayName = principal.FindFirst(ClaimTypes.Name)?.Value
            ?? principal.FindFirst("name")?.Value
            ?? string.Empty;
        if (string.IsNullOrWhiteSpace(displayName))
        {
            string composed = $"{firstName} {lastName}".Trim();
            displayName = string.IsNullOrWhiteSpace(composed) ? email : composed;
        }

        return await ProvisionInternalAsync(
            externalUserId,
            email,
            displayName,
            firstName,
            lastName,
            cancellationToken);
    }

    /// <inheritdoc/>
    public async Task<Result<User>> ProvisionAsync(
        string externalUserId,
        string email,
        string displayName,
        string? firstName,
        string? lastName,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(externalUserId))
        {
            return Result<User>.Failure("ExternalUserId is required.");
        }
        if (string.IsNullOrWhiteSpace(email))
        {
            return Result<User>.Failure("Email is required.");
        }
        if (string.IsNullOrWhiteSpace(displayName))
        {
            return Result<User>.Failure("DisplayName is required.");
        }

        return await ProvisionInternalAsync(
            externalUserId,
            email,
            displayName,
            firstName,
            lastName,
            cancellationToken);
    }

    private async Task<Result<User>> ProvisionInternalAsync(
        string externalUserId,
        string email,
        string displayName,
        string? firstName,
        string? lastName,
        CancellationToken cancellationToken)
    {
        User? existing = await _userRepository.GetByExternalUserIdAsync(externalUserId, cancellationToken);
        if (existing is not null)
        {
            return Result<User>.Success(existing);
        }

        User provisioned = await _userRepository.ProvisionAsync(
            externalUserId,
            email,
            displayName,
            firstName,
            lastName,
            roleId: 1,
            cancellationToken);

        _logger.LogInformation(
            "JIT-provisioned user {ExternalUserId} (UserId={UserId}, Email={Email}). Default RoleId=1; admin must elevate if needed.",
            externalUserId,
            provisioned.UserId,
            email);

        return Result<User>.Success(provisioned);
    }
}
