namespace ARA.Domain.Entities;

/// <summary>
/// Stores the Controller section data for an ARA.
/// Maps to the legacy <c>ara_con</c> table. Required for Non-Early Start ARAs only.
/// The auto-calculated totals (<see cref="TotalCost"/>, <see cref="TotalFee"/>) are
/// computed by the database stored procedure and must never be entered manually.
/// </summary>
public sealed class AraControllerSection
{
    /// <summary>Gets the primary key. Maps to legacy <c>id_ara_con</c>.</summary>
    public int AraControllerSectionId { get; init; }

    /// <summary>Gets the ID of the owning ARA. Maps to legacy <c>id_ara</c>.</summary>
    public int AraId { get; init; }

    /// <summary>Gets the ID of the Controller user who completed this section. Maps to legacy <c>id_user</c>.</summary>
    public int ControllerId { get; init; }

    /// <summary>
    /// Gets the interest impact value entered by the Controller.
    /// Stored as <c>float</c> in legacy <c>ara_con.interestImpact</c>.
    /// Definition confirmed from legacy schema; unit/calculation source still unresolved (ambiguity #4).
    /// </summary>
    public double? InterestImpact { get; init; }

    /// <summary>
    /// Gets the expected burn rate entered by the Controller.
    /// Stored as <c>float</c> in legacy <c>ara_con.burnRate</c>.
    /// Definition confirmed from legacy schema; calculation source still unresolved (ambiguity #4).
    /// </summary>
    public double? BurnRate { get; init; }

    /// <summary>
    /// Gets the auto-calculated total cost across all CLINs.
    /// Populated by the database; never entered manually. Maps to legacy <c>ara_con.total_cost</c>.
    /// </summary>
    public double? TotalCost { get; init; }

    /// <summary>
    /// Gets the auto-calculated total fee across all CLINs.
    /// Populated by the database; never entered manually. Maps to legacy <c>ara_con.total_fee</c>.
    /// </summary>
    public double? TotalFee { get; init; }

    /// <summary>Gets the incurred costs entered by the Controller. Maps to legacy <c>ara_con.icCost</c>.</summary>
    public double? IncurredCost { get; init; }

    /// <summary>Gets the incurred fees entered by the Controller. Maps to legacy <c>ara_con.icFee</c>.</summary>
    public double? IncurredFee { get; init; }

    /// <summary>Gets the company code entered by the Controller. Maps to legacy <c>ara_con.company</c>.</summary>
    public string? Company { get; init; }
}
