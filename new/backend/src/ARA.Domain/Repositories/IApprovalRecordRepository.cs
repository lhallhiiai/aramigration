using ARA.Domain.Entities;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for ApprovalRecord entries.
/// The ordered collection of records for an ARA forms its Approval Cycle.
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IApprovalRecordRepository
{
    /// <summary>
    /// Retrieves all approval records for a given ARA, ordered by
    /// <see cref="ApprovalRecord.SequenceOrder"/> then <see cref="ApprovalRecord.ActionTakenAt"/>.
    /// </summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<ApprovalRecord>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves all approval records for a given ARA scoped to a specific revision.
    /// Used to display the Approval Cycle for the current submission only.
    /// </summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="revision">The ARA revision number to scope results to.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<ApprovalRecord>> GetByAraIdAndRevisionAsync(int araId, int revision, CancellationToken cancellationToken = default);

    /// <summary>
    /// Persists a new approval action record. Records are never updated or deleted;
    /// the approval history is append-only.
    /// </summary>
    /// <param name="record">The approval action to persist.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task CreateAsync(ApprovalRecord record, CancellationToken cancellationToken = default);
}
