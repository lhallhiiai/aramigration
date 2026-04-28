using System.Security.Claims;
using ARA.Application.Users;
using ARA.Domain.Repositories;

namespace ARA.Api;

/// <summary>
/// Resolves the authenticated caller to a local database user record.
/// Returns null only when no caller is authenticated. The JIT user provisioning
/// middleware (registered before authorization) ensures every authenticated
/// caller has a row before this method runs, so a missing row past that point
/// is a hard failure rather than a silent null.
/// </summary>
public sealed class CurrentUserService : ICurrentUserService
{
    private readonly IUserRepository _userRepository;
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly ILogger<CurrentUserService> _logger;

    /// <summary>Initializes a new instance of <see cref="CurrentUserService"/>.</summary>
    public CurrentUserService(
        IUserRepository userRepository,
        IHttpContextAccessor httpContextAccessor,
        ILogger<CurrentUserService> logger)
    {
        _userRepository = userRepository;
        _httpContextAccessor = httpContextAccessor;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<UserDto?> GetCurrentUserAsync(CancellationToken cancellationToken = default)
    {
        ClaimsPrincipal? principal = _httpContextAccessor.HttpContext?.User;
        if (principal?.Identity?.IsAuthenticated != true)
            return null;

        // Production: Okta sets the "sub" claim.
        // Dev bypass (DevAuthenticationHandler): falls back to NameIdentifier.
        string? externalUserId = principal.FindFirstValue("sub")
            ?? principal.FindFirstValue(ClaimTypes.NameIdentifier);

        if (string.IsNullOrWhiteSpace(externalUserId))
        {
            throw new InvalidOperationException(
                "Authenticated principal has no sub or NameIdentifier claim. JIT provisioning should have rejected the request before reaching this point.");
        }

        ARA.Domain.Entities.User? user = await _userRepository.GetByExternalUserIdAsync(externalUserId, cancellationToken);
        if (user is null)
        {
            throw new InvalidOperationException(
                $"Authenticated user '{externalUserId}' has no local user row. JIT provisioning should have created one before reaching this point.");
        }

        return new UserDto(user.UserId, user.DisplayName, user.FirstName, user.LastName, user.Email, user.Role, user.JobTitleId);
    }
}
