using ARA.Application.Common;

namespace ARA.Application.Delegation;

/// <summary>
/// Manages user delegation of approval authority.
/// Business rules: no self-delegation, no concurrent active delegations per delegator,
/// admin users cannot delegate.
/// </summary>
public interface IDelegationService
{
    /// <summary>Returns all currently active delegations across all users.</summary>
    Task<IReadOnlyList<DelegationDto>> GetActiveDelegationsAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Creates a new delegation from the authenticated user to the specified delegatee.
    /// Returns the newly assigned DelegationId.
    /// </summary>
    Task<Result<int>> CreateDelegationAsync(CreateDelegationRequest request, int delegatorUserId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Deactivates a delegation. Only the delegator or an admin may deactivate.
    /// </summary>
    Task<Result> DeactivateDelegationAsync(int delegationId, int userId, CancellationToken cancellationToken = default);
}
