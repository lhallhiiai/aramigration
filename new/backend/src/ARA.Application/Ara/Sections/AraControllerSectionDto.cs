namespace ARA.Application.Ara.Sections;

/// <summary>Controller section data for an ARA.</summary>
public sealed record AraControllerSectionDto(
    int AraControllerSectionId,
    int AraId,
    int ControllerId,
    double? InterestImpact,
    double? BurnRate,
    double? TotalCost,
    double? TotalFee,
    double? IncurredCost,
    double? IncurredFee,
    string? Company);
