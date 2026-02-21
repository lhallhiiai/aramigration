using ARA.Domain.Enums;

namespace ARA.Application.Users;

/// <summary>Reads user data for role-based lookups and dropdown population.</summary>
public interface IUserService
{
    /// <summary>Returns active users with the specified role.</summary>
    Task<IReadOnlyList<UserDto>> GetByRoleAsync(UserRole role, CancellationToken cancellationToken = default);

    /// <summary>Returns all active users across all roles.</summary>
    Task<IReadOnlyList<UserDto>> GetAllActiveAsync(CancellationToken cancellationToken = default);
}
