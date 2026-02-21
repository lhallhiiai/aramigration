namespace ARA.Application.Users;

/// <summary>
/// Resolves the authenticated caller to a local <see cref="UserDto"/> record.
/// Returns null when the caller is not yet provisioned in the local database
/// (e.g. the development auto-user or a first-time Entra sign-in).
/// </summary>
public interface ICurrentUserService
{
    /// <summary>Gets the local user record for the current HTTP request, or null if not found.</summary>
    Task<UserDto?> GetCurrentUserAsync(CancellationToken cancellationToken = default);
}
