using ARA.Domain.Enums;

namespace ARA.Domain.Entities;

/// <summary>
/// Records a single action taken by an approver on an ARA.
/// The ordered collection of ApprovalRecords for an ARA forms its Approval Cycle,
/// displayed as the read-only approval history on the Approvals page.
/// </summary>
public sealed class ApprovalRecord
{
    /// <summary>Gets the unique identifier for this approval record (primary key).</summary>
    public int ApprovalRecordId { get; init; }

    /// <summary>Gets the ID of the ARA this record belongs to.</summary>
    public int AraId { get; init; }

    /// <summary>Gets the ID of the approver who took this action.</summary>
    public int ApproverId { get; init; }

    /// <summary>Gets the action taken by the approver: Review, Approve, or Reject.</summary>
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
    /// Gets the reason code for a rejection.
    /// Only populated when <see cref="Action"/> is <see cref="ApprovalActionType.Reject"/>.
    /// </summary>
    public string? RejectionReasonCode { get; init; }

    /// <summary>
    /// Gets the ARA tab flagged by the approver to focus resubmission effort.
    /// Only populated when <see cref="Action"/> is <see cref="ApprovalActionType.Reject"/>.
    /// </summary>
    public AraTab? RejectionAffectedTab { get; init; }

    /// <summary>Gets the UTC timestamp when this action was recorded.</summary>
    public DateTime ActionTakenAt { get; init; }

    /// <summary>
    /// Gets the ARA revision number at the time this action was taken.
    /// Allows the approval history to be scoped correctly across rejection cycles.
    /// </summary>
    public int AraRevision { get; init; }
}
