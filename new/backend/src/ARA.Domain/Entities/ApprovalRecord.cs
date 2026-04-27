using ARA.Domain.Enums;

namespace ARA.Domain.Entities;

/// <summary>
/// Records a single action taken by a user on an ARA.
/// The ordered collection of ApprovalRecords for an ARA forms its Approval Cycle,
/// displayed as the read-only approval history on the Approvals page.
/// Maps to the legacy <c>araAppLog</c> table (new name: <c>AraApprovalLog</c>).
/// </summary>
public sealed class ApprovalRecord
{
    /// <summary>Gets the unique identifier for this approval record (primary key). Maps to <c>AraApprovalLogId</c>.</summary>
    public int ApprovalRecordId { get; init; }

    /// <summary>Gets the ID of the ARA this record belongs to.</summary>
    public int AraId { get; init; }

    /// <summary>Gets the ID of the user who took this action. Maps to legacy <c>UserId</c>.</summary>
    public int? ApproverId { get; init; }

    /// <summary>Gets the job title of the acting user at the time of the action. Maps to legacy <c>JobTitleId</c>.</summary>
    public int? JobTitleId { get; init; }

    /// <summary>
    /// Gets the action taken: Review, Approve, or Reject.
    /// Derived from <c>IsRejection</c> and <c>StatusId</c> in the stored procedure.
    /// </summary>
    public ApprovalActionType Action { get; init; }

    /// <summary>
    /// Gets the sequence position of this approver in the approval chain as determined
    /// by the Approval and Threshold Matrix. Lower numbers act first.
    /// </summary>
    public int SequenceOrder { get; init; }

    /// <summary>
    /// Gets the approver's comment. Required when <see cref="Action"/> is
    /// <see cref="ApprovalActionType.Reject"/>; optional otherwise.
    /// </summary>
    public string? Comment { get; init; }

    /// <summary>
    /// Gets the foreign key to the <c>RejectionReason</c> lookup table.
    /// Only populated when <see cref="Action"/> is <see cref="ApprovalActionType.Reject"/>.
    /// Maps to legacy <c>RejectionReasonId</c>.
    /// </summary>
    public int? RejectionReasonId { get; init; }

    /// <summary>
    /// Gets the free-text description of affected ARA areas flagged by the approver for resubmission.
    /// Only populated when <see cref="Action"/> is <see cref="ApprovalActionType.Reject"/>.
    /// Maps to legacy <c>RejectionAreas</c>.
    /// </summary>
    public string? RejectionAreas { get; init; }

    /// <summary>
    /// Gets the ID of the original delegator when this action was taken via delegation.
    /// Null when the approver acted directly (not through delegation).
    /// When set, <see cref="ApproverId"/> is the delegatee who physically took the action.
    /// </summary>
    public int? DelegatorUserId { get; init; }

    /// <summary>Gets the UTC timestamp when this action was recorded. Maps to legacy <c>ActionDate</c>.</summary>
    public DateTime ActionTakenAt { get; init; }

    /// <summary>
    /// Gets the ARA revision (cycle) number at the time this action was taken.
    /// Allows the approval history to be scoped correctly across rejection cycles.
    /// Maps to legacy <c>Cycle</c>.
    /// </summary>
    public int AraRevision { get; init; }
}
