namespace ARA.Application.Clin;

/// <summary>CLIN worksheet entry returned to the client.</summary>
public sealed record ClinEntryDto(
    int ClinEntryId,
    int AraId,
    string ClinNumber,
    string? ClinDescription,
    decimal Cost,
    decimal Fee,
    decimal Total);
