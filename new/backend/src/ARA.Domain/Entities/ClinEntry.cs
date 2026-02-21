namespace ARA.Domain.Entities;

/// <summary>
/// Represents a single Contract Line Item Number (CLIN) entry on the Controller's
/// CLIN Worksheet. Required for Non-Early Start ARAs only. Each CLIN identifier
/// from JAMIS may be used at most once per ARA.
/// </summary>
public sealed class ClinEntry
{
    /// <summary>Gets the unique identifier for this CLIN entry (primary key).</summary>
    public int ClinEntryId { get; init; }

    /// <summary>Gets the ID of the ARA this CLIN entry belongs to.</summary>
    public int AraId { get; init; }

    /// <summary>
    /// Gets the CLIN identifier as pre-populated from JAMIS for the ARA's contract.
    /// Each value may appear at most once per ARA.
    /// </summary>
    public string ClinNumber { get; init; } = string.Empty;

    /// <summary>Gets the CLIN description as retrieved from JAMIS.</summary>
    public string? ClinDescription { get; init; }

    /// <summary>Gets the cost amount allocated to this CLIN by the Controller.</summary>
    public decimal Cost { get; init; }

    /// <summary>Gets the fee amount allocated to this CLIN by the Controller.</summary>
    public decimal Fee { get; init; }

    /// <summary>
    /// Gets the auto-calculated total for this CLIN entry (Cost + Fee).
    /// The system must display this value; it must never be entered manually.
    /// </summary>
    public decimal Total => Cost + Fee;

    /// <summary>Gets the UTC timestamp when this CLIN entry was added.</summary>
    public DateTime CreatedAt { get; init; }

    /// <summary>Gets the UTC timestamp of the most recent update to this CLIN entry.</summary>
    public DateTime UpdatedAt { get; init; }
}
