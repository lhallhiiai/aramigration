using ARA.Domain.Entities;
using ARA.Domain.Enums;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for ARA records.
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IAraRepository
{
    /// <summary>Retrieves a single ARA by its unique system identifier.</summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>The matching <see cref="Ara"/>, or null if not found.</returns>
    Task<Ara?> GetByIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves ARAs currently awaiting action from a specific user, based on their
    /// role and the ARA's current status. Drives the My Action List on the landing page.
    /// </summary>
    /// <param name="userId">The user's primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<Ara>> GetPendingForUserAsync(int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves all ARAs currently in circulation (non-terminal statuses).
    /// Drives the See All ARAs view on the landing page.
    /// </summary>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<Ara>> GetAllActiveAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves ARAs filtered by status. Used by the Dashboard to display
    /// pending ARAs grouped by status.
    /// </summary>
    /// <param name="status">The status to filter by.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<Ara>> GetByStatusAsync(AraStatus status, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves ARAs in Exported status, accessible via the Archived menu.
    /// Includes Negated ARAs for historical reference.
    /// </summary>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<Ara>> GetArchivedAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves ARAs matching a partial or full ARA ID or JAMIS ID search term.
    /// Drives the Quick Search function.
    /// </summary>
    /// <param name="searchTerm">Partial or full ARA ID or JAMIS ID.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<Ara>> SearchByIdAsync(string searchTerm, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves ARAs sorted by expected expiration date for the Dashboard
    /// critical expirations view.
    /// </summary>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<Ara>> GetUpcomingExpirationsAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Creates a new ARA record and returns the system-assigned AraId.
    /// </summary>
    /// <param name="ara">The ARA data to persist.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>The newly assigned AraId.</returns>
    Task<int> CreateAsync(Ara ara, CancellationToken cancellationToken = default);

    /// <summary>Persists changes to an existing ARA record.</summary>
    /// <param name="ara">The updated ARA data.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task UpdateAsync(Ara ara, CancellationToken cancellationToken = default);

    /// <summary>
    /// Updates only the status, revision, and optional lifecycle timestamps of an ARA.
    /// Used by all workflow transition methods (Submit, Approve, Reject, Cancel, Negate)
    /// to avoid rewriting all ARA fields on every state change.
    /// </summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="newStatus">The new lifecycle status.</param>
    /// <param name="revision">The revision counter value (incremented on rejection).</param>
    /// <param name="cancelledAt">Set to the cancellation timestamp when transitioning to Cancelled; otherwise null.</param>
    /// <param name="negatedAt">Set to the negation timestamp when transitioning to Negated; otherwise null.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task UpdateStatusAsync(
        int araId,
        AraStatus newStatus,
        int revision,
        DateTime? cancelledAt = null,
        DateTime? negatedAt = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Bulk-expires all active ARAs whose expiration date has passed.
    /// Returns the count of ARAs that were transitioned to Expired status.
    /// Called by the hourly <c>AraExpirationHostedService</c>.
    /// </summary>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<int> ExpireOverdueAsync(CancellationToken cancellationToken = default);
}
