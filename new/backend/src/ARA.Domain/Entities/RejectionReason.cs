namespace ARA.Domain.Entities;

/// <summary>
/// Represents a predefined reason code selected by an approver when rejecting an ARA.
/// Maps to the <c>RejectionReason</c> lookup table. The seven predefined codes are:
/// Supporting Documentation is Insufficient, Incorrect CLIN Number Used,
/// Incorrect Amount Entered, Amount and Supporting docs do not match,
/// Inadequate comments justification on form, Other, ARA no longer needed.
/// </summary>
public sealed class RejectionReason
{
    /// <summary>Gets the primary key (1–7).</summary>
    public int RejectionReasonId { get; init; }

    /// <summary>Gets the display text of the rejection reason (e.g. "Incorrect Amount Entered").</summary>
    public string Description { get; init; } = string.Empty;

    /// <summary>Gets the UI sort order for the dropdown display.</summary>
    public int DisplayOrder { get; init; }

    /// <summary>Gets whether this reason code is inactive and should be excluded from the UI.</summary>
    public bool IsInactive { get; init; }
}
