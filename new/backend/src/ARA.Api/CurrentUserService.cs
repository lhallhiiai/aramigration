using System.Security.Claims;
using ARA.Application.Users;
using ARA.Domain.Repositories;

namespace ARA.Api;

/// <summary>
/// Resolves the authenticated caller to a local database user record.
/// Returns null when no matching record exists (e.g. the dev user seed has not been inserted).
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
        if (principal is null)
            return null;

        // Production: Okta sets the "sub" claim.
        // Dev bypass (DevAuthenticationHandler): falls back to NameIdentifier.
        string? externalUserId = principal.FindFirstValue("sub")
            ?? principal.FindFirstValue(ClaimTypes.NameIdentifier);

        if (string.IsNullOrWhiteSpace(externalUserId))
        {
            _logger.LogWarning("No identity claim found on authenticated principal.");
            return null;
        }

        ARA.Domain.Entities.User? user = await _userRepository.GetByExternalUserIdAsync(externalUserId, cancellationToken);
        if (user is null)
        {
            _logger.LogWarning("Authenticated user {ExternalUserId} has no matching database record.", externalUserId);
            return null;
        }

        return new UserDto(user.UserId, user.DisplayName, user.FirstName, user.LastName, user.Email, user.Role, user.JobTitleId);
    }
}
