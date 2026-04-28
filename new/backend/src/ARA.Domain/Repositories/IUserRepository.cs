using ARA.Domain.Entities;
using ARA.Domain.Enums;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for User records.
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IUserRepository
{
    /// <summary>Retrieves a user by their unique local identifier.</summary>
    /// <param name="userId">The user's primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>The matching <see cref="User"/>, or null if not found.</returns>
    Task<User?> GetByIdAsync(int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves a user by their external identity provider subject identifier.
    /// Used to resolve the authenticated caller (Okta <c>sub</c> claim) to a local user record.
    /// </summary>
    /// <param name="externalUserId">The Okta subject identifier from the <c>sub</c> claim.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>The matching <see cref="User"/>, or null if not found.</returns>
    Task<User?> GetByExternalUserIdAsync(string externalUserId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves all active users with the specified role.
    /// Used to populate the Contract Administrator and Controller assignment dropdowns
    /// on the ARA creation Step 2 screen.
    /// </summary>
    /// <param name="role">The role to filter by.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<User>> GetByRoleAsync(UserRole role, CancellationToken cancellationToken = default);

    /// <summary>Retrieves all active users across all roles.</summary>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<User>> GetAllActiveAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves all active users with the specified job title.
    /// Used by the approval routing engine to find candidate approvers for a matrix step.
    /// </summary>
    /// <param name="jobTitleId">The job title identifier to filter by.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<User>> GetByJobTitleIdAsync(int jobTitleId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Provisions a user record for the given external identity. If a row already exists for
    /// <paramref name="externalUserId"/>, returns it unchanged; otherwise creates a new row using
    /// the supplied claims. The implementation must be idempotent on re-run.
    /// </summary>
    /// <param name="externalUserId">The Okta subject identifier (sub claim) for the user.</param>
    /// <param name="email">The user's email address.</param>
    /// <param name="displayName">The user's full display name.</param>
    /// <param name="firstName">The user's first name, if available.</param>
    /// <param name="lastName">The user's last name, if available.</param>
    /// <param name="roleId">The role to assign on first creation. Defaults to 1 (Creator/PM).</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>The user row that ends up in the database (existing or newly created).</returns>
    Task<User> ProvisionAsync(
        string externalUserId,
        string email,
        string displayName,
        string? firstName,
        string? lastName,
        int roleId = 1,
        CancellationToken cancellationToken = default);
}
