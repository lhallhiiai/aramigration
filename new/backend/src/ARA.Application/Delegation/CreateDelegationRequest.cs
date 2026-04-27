namespace ARA.Application.Delegation;

/// <summary>
/// Payload for creating a new delegation of approval authority.
/// </summary>
public sealed record CreateDelegationRequest(
    int DelegateeUserId,
    DateTime StartDate,
    DateTime EndDate);
