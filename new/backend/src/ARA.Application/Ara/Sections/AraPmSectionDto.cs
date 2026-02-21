namespace ARA.Application.Ara.Sections;

/// <summary>PM narrative section data for an ARA.</summary>
public sealed record AraPmSectionDto(
    int AraPmSectionId,
    int AraId,
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
