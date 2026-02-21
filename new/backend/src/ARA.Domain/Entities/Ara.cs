using ARA.Domain.Enums;

namespace ARA.Domain.Entities;

/// <summary>
/// The central aggregate for an At Risk Authorization.
/// Tracks all data fields, workflow stage submissions, and lifecycle status
/// for a single ARA record across the PM, CA, Controller, and Approver stages.
/// </summary>
public sealed class Ara
{
    /// <summary>Gets the unique system-assigned identifier for this ARA (primary key).</summary>
    public int AraId { get; init; }

    /// <summary>
    /// Gets the JAMIS-assigned identifier for this ARA, populated after the ARA is
    /// exported to JAMIS. Null until export occurs.
    /// </summary>
    public string? JamisId { get; init; }

    /// <summary>
    /// Gets the risk category selected when the ARA was created. Drives the branching
    /// between Early Start and Non-Early Start workflow paths.
    /// </summary>
    public RiskCategory RiskCategory { get; init; }

    /// <summary>
    /// Gets the ARA authorization type: Authority to Spend Only, or Authority to Spend
    /// with Revenue Recognition.
    /// </summary>
    public AraType AraType { get; init; }

    /// <summary>Gets the current lifecycle status of the ARA.</summary>
    public AraStatus Status { get; init; }

    /// <summary>
    /// Gets the revision counter. Increments each time the ARA is rejected and resubmitted.
    /// The exact incrementing behavior is an unresolved ambiguity (item 3 in CLAUDE.md);
    /// this field must not be used for business logic until that ambiguity is resolved.
    /// </summary>
    public int Revision { get; init; }

    // ── Org fields (validated against JAMIS autocomplete) ─────────────────────

    /// <summary>Gets the JAMIS Org sector component.</summary>
    public string? OrgSector { get; init; }

    /// <summary>Gets the JAMIS Org group component.</summary>
    public string? OrgGroup { get; init; }

    /// <summary>Gets the JAMIS Org operation component.</summary>
    public string? OrgOperation { get; init; }

    /// <summary>Gets the JAMIS Org division component.</summary>
    public string? OrgDivision { get; init; }

    /// <summary>Gets the JAMIS Org description.</summary>
    public string? OrgDescription { get; init; }

    // ── Contract reference (mutually exclusive by risk category) ──────────────

    /// <summary>
    /// Gets the JAMIS contract number, validated against live JAMIS data.
    /// Populated for Non-Early Start ARAs only; null for Early Start.
    /// </summary>
    public string? JamisContractNumber { get; init; }

    /// <summary>
    /// Gets the OMS opportunity number, validated against live OMS data.
    /// Populated for Early Start (Pre-Contract Costs) ARAs only; null for Non-Early Start.
    /// OMS number format and validation rules are an unresolved ambiguity (item 10 in CLAUDE.md).
    /// </summary>
    public string? OmsNumber { get; init; }

    // ── Early Start-only fields ────────────────────────────────────────────────

    /// <summary>
    /// Gets the ARA title entered during Step 2 creation.
    /// Required for Early Start ARAs; null for Non-Early Start.
    /// </summary>
    public string? Title { get; init; }

    /// <summary>
    /// Gets the customer name entered during Step 2 creation.
    /// Required for Early Start ARAs; null for Non-Early Start.
    /// </summary>
    public string? Customer { get; init; }

    // ── User assignments set at creation ──────────────────────────────────────

    /// <summary>Gets the ID of the Creator (Program Manager) who owns this ARA.</summary>
    public int CreatorId { get; init; }

    /// <summary>Gets the ID of the Contract Administrator assigned at creation.</summary>
    public int ContractAdministratorId { get; init; }

    /// <summary>Gets the ID of the Controller assigned at creation.</summary>
    public int ControllerId { get; init; }

    // ── PM section ────────────────────────────────────────────────────────────

    /// <summary>
    /// Gets the total ARA amount set by the PM. Enforces the CLIN funding cap
    /// (combined Cost + Fee across all CLINs must not exceed this value) and
    /// determines whether the $50,000 question threshold applies.
    /// </summary>
    public decimal? AraAmount { get; init; }

    /// <summary>Gets the UTC timestamp of the PM's most recent save.</summary>
    public DateTime? PmSavedAt { get; init; }

    /// <summary>Gets the UTC timestamp when the PM signed and submitted the ARA.</summary>
    public DateTime? PmSubmittedAt { get; init; }

    // ── Contract Administrator section ────────────────────────────────────────

    /// <summary>Gets the UTC timestamp of the CA's most recent save.</summary>
    public DateTime? CaSavedAt { get; init; }

    /// <summary>Gets the UTC timestamp when the CA submitted the ARA for next approval.</summary>
    public DateTime? CaSubmittedAt { get; init; }

    // ── Controller section ────────────────────────────────────────────────────

    /// <summary>Gets the company name entered by the Controller.</summary>
    public string? Company { get; init; }

    /// <summary>
    /// Gets the interest impact value entered by the Controller.
    /// The definition, data type, and calculation source for this field are an
    /// unresolved ambiguity (item 4 in CLAUDE.md).
    /// </summary>
    public decimal? InterestImpact { get; init; }

    /// <summary>
    /// Gets the expected burn rate entered by the Controller.
    /// The definition, data type, and calculation source for this field are an
    /// unresolved ambiguity (item 4 in CLAUDE.md).
    /// </summary>
    public decimal? ExpectedBurnRate { get; init; }

    /// <summary>Gets the costs already incurred against this ARA, entered by the Controller.</summary>
    public decimal? IncurredCosts { get; init; }

    /// <summary>Gets the fees already incurred against this ARA, entered by the Controller.</summary>
    public decimal? IncurredFee { get; init; }

    /// <summary>Gets the UTC timestamp of the Controller's most recent save.</summary>
    public DateTime? ControllerSavedAt { get; init; }

    /// <summary>Gets the UTC timestamp when the Controller submitted the ARA for approval.</summary>
    public DateTime? ControllerSubmittedAt { get; init; }

    // ── Lifecycle timestamps ──────────────────────────────────────────────────

    /// <summary>Gets the UTC timestamp when the ARA record was created.</summary>
    public DateTime CreatedAt { get; init; }

    /// <summary>Gets the UTC timestamp of the most recent update to this ARA record.</summary>
    public DateTime UpdatedAt { get; init; }

    /// <summary>
    /// Gets the expected expiration date displayed on the Dashboard sorted view.
    /// Expiration logic (how this date is set and what triggers the Expired status
    /// transition) is an unresolved ambiguity (item 11 in CLAUDE.md).
    /// </summary>
    public DateTime? ExpectedExpirationDate { get; init; }

    /// <summary>Gets the UTC timestamp when the ARA was exported to JAMIS.</summary>
    public DateTime? ExportedAt { get; init; }

    /// <summary>Gets the UTC timestamp when the CA negated this ARA.</summary>
    public DateTime? NegatedAt { get; init; }

    /// <summary>Gets the UTC timestamp when the PM cancelled this ARA.</summary>
    public DateTime? CancelledAt { get; init; }
}
