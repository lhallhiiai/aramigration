using ARA.Domain.Entities;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for user delegation records.
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IDelegationRepository
{
    /// <summary>
    /// Retrieves the currently active delegation for a given delegator, if any.
    /// A delegation is active when <c>IsActive = true</c> and the current date
    /// falls within the <c>StartDate</c>–<c>EndDate</c> range.
    /// </summary>
    /// <param name="delegatorUserId">The delegator's user ID.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<Delegation?> GetActiveDelegationForUserAsync(int delegatorUserId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves all active delegations where the specified user is the delegatee.
    /// Used by the approval routing engine to check if an acting user holds
    /// delegated authority from any approver.
    /// </summary>
    /// <param name="delegateeUserId">The delegatee's user ID.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<Delegation>> GetActiveDelegationsForDelegateeAsync(int delegateeUserId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves all currently active delegations across all users.
    /// Used for the System Information delegations display.
    /// </summary>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<Delegation>> GetActiveDelegationsAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Creates a new delegation record and returns the system-assigned DelegationId.
    /// </summary>
    /// <param name="delegation">The delegation data to persist.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>The newly assigned DelegationId.</returns>
    Task<int> CreateAsync(Delegation delegation, CancellationToken cancellationToken = default);

    /// <summary>
    /// Deactivates a delegation by setting <c>IsActive = false</c>.
    /// </summary>
    /// <param name="delegationId">The delegation primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task DeactivateAsync(int delegationId, CancellationToken cancellationToken = default);
}
