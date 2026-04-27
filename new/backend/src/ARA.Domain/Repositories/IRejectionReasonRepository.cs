using ARA.Domain.Entities;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for the <c>RejectionReason</c> lookup table.
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IRejectionReasonRepository
{
    /// <summary>Retrieves all active rejection reason codes ordered by display order.</summary>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<RejectionReason>> GetAllActiveAsync(CancellationToken cancellationToken = default);

    /// <summary>Retrieves a single rejection reason by its identifier.</summary>
    /// <param name="rejectionReasonId">The rejection reason primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<RejectionReason?> GetByIdAsync(int rejectionReasonId, CancellationToken cancellationToken = default);
}
