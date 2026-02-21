namespace ARA.Application.Ara.Sections;

/// <summary>Payload for saving (creating or updating) the PM narrative section of an ARA.</summary>
public sealed record SaveAraPmSectionRequest(
    string? FundsInAdvance,
    string? ContractDefinization,
    string? PertinentInformation,
    string? WorkStarted,
    string? Consequence,
    string? CurrentStatus,
    string? ChangeInScope,
    string? ActionToClear,
    string? EarlyStartNecessary,
    string? OtherNecessary);
