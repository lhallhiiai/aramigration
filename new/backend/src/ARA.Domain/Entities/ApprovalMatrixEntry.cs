using ARA.Domain.Enums;

namespace ARA.Domain.Entities;

/// <summary>
/// Represents a single row in the Approval and Threshold Matrix configuration table.
/// Each entry defines one sequential approval step, the job title required to satisfy it,
/// the action type (Approve or Review), and the minimum ARA dollar amount that activates it.
/// Steps 1–3 (PM, CA, Controller) are display-only; the routing engine processes steps 4–10.
/// </summary>
public sealed class ApprovalMatrixEntry
{
    /// <summary>Gets the primary key for this matrix entry.</summary>
    public int ApprovalMatrixEntryId { get; init; }

    /// <summary>
    /// Gets the sequential position of this step in the approval chain (1–10).
    /// Lower values act first. The routing engine only processes entries with
    /// <see cref="SequenceOrder"/> &gt;= 4 (post-Controller steps).
    /// </summary>
    public int SequenceOrder { get; init; }

    /// <summary>Gets the display name for this approval role (e.g. "Portfolio Leader", "MTC COO").</summary>
    public string RoleName { get; init; } = string.Empty;

    /// <summary>
    /// Gets the foreign key to <see cref="JobTitle"/>. The routing engine matches this
    /// against <see cref="User.JobTitleId"/> to find eligible approvers for the step.
    /// </summary>
    public int JobTitleId { get; init; }

    /// <summary>
    /// Gets the action the approver must take at this step: <see cref="ApprovalActionType.Approve"/>
    /// or <see cref="ApprovalActionType.Review"/>. Both advance the chain; the difference is semantic.
    /// </summary>
    public ApprovalActionType RequiredAction { get; init; }

    /// <summary>
    /// Gets the minimum ARA amount (inclusive) that activates this step.
    /// Steps 4–7 use 0 (always active); steps 8–10 use 500,000 (only for ARAs &gt;= $500K).
    /// </summary>
    public decimal MinimumAmount { get; init; }

    /// <summary>Gets whether this approval step can be delegated to another user.</summary>
    public bool IsDelegable { get; init; }

    /// <summary>Gets whether this matrix entry is inactive (excluded from routing).</summary>
    public bool IsInactive { get; init; }
}
