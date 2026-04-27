namespace ARA.Domain.Entities;

/// <summary>
/// Represents a delegation of approval authority from one user to another.
/// When active, the delegatee receives email notifications the delegator would
/// have received and may act on ARAs in the delegator's place. Any user except
/// admin may delegate. A delegation is active when <see cref="IsActive"/> is true
/// and the current UTC time falls between <see cref="StartDate"/> and <see cref="EndDate"/>.
/// </summary>
public sealed class Delegation
{
    /// <summary>Gets the primary key for this delegation record.</summary>
    public int DelegationId { get; init; }

    /// <summary>Gets the ID of the user delegating their approval authority.</summary>
    public int DelegatorUserId { get; init; }

    /// <summary>Gets the ID of the user receiving the delegated approval authority.</summary>
    public int DelegateeUserId { get; init; }

    /// <summary>Gets the start of the delegation period (inclusive, UTC).</summary>
    public DateTime StartDate { get; init; }

    /// <summary>Gets the end of the delegation period (inclusive, UTC).</summary>
    public DateTime EndDate { get; init; }

    /// <summary>Gets whether this delegation is active. Combined with the date range to determine eligibility.</summary>
    public bool IsActive { get; init; }

    /// <summary>Gets the UTC timestamp when this delegation record was created.</summary>
    public DateTime CreatedAt { get; init; }
}
