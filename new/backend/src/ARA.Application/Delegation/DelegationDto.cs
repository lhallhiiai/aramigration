namespace ARA.Application.Delegation;

/// <summary>
/// Data transfer object representing a delegation record for API responses.
/// </summary>
public sealed record DelegationDto(
    int DelegationId,
    int DelegatorUserId,
    string DelegatorDisplayName,
    int DelegateeUserId,
    string DelegateeDisplayName,
    DateTime StartDate,
    DateTime EndDate,
    bool IsActive);
