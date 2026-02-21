namespace ARA.Application.Ara.Sections;

/// <summary>Payload for saving (creating or updating) the Controller section of an ARA.</summary>
public sealed record SaveAraControllerSectionRequest(
    double? InterestImpact,
    double? BurnRate,
    double? IncurredCost,
    double? IncurredFee,
    string? Company);
