namespace ARA.Application.Approval;

/// <summary>Reads the approval history for an ARA.</summary>
public interface IApprovalRecordService
{
    /// <summary>Returns all approval records for the given ARA across all revisions.</summary>
    Task<IReadOnlyList<ApprovalRecordDto>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Returns approval records for the given ARA scoped to a specific revision.
    /// Use this to display the Approval Cycle for the current submission only.
    /// </summary>
    Task<IReadOnlyList<ApprovalRecordDto>> GetByAraIdAndRevisionAsync(int araId, int revision, CancellationToken cancellationToken = default);
}
