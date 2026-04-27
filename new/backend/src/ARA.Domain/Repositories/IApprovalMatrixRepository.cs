using ARA.Domain.Entities;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for the Approval and Threshold Matrix configuration.
/// The matrix is stored in the database as a configurable system setting (never hard-coded).
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IApprovalMatrixRepository
{
    /// <summary>
    /// Retrieves all active matrix entries ordered by <see cref="ApprovalMatrixEntry.SequenceOrder"/>.
    /// Includes display-only entries (steps 1–3) for the System Information page.
    /// </summary>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<ApprovalMatrixEntry>> GetActiveEntriesAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves matrix entries required for a given ARA amount. Returns only entries
    /// with <see cref="ApprovalMatrixEntry.SequenceOrder"/> &gt;= 4 (post-Controller steps)
    /// and <see cref="ApprovalMatrixEntry.MinimumAmount"/> &lt;= <paramref name="amount"/>,
    /// ordered by SequenceOrder ascending.
    /// </summary>
    /// <param name="amount">The total ARA amount to evaluate against thresholds.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<ApprovalMatrixEntry>> GetRequiredEntriesForAmountAsync(decimal amount, CancellationToken cancellationToken = default);
}
