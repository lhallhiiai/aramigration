namespace ARA.Application.Clin;

/// <summary>Payload for updating Cost and Fee on an existing CLIN entry.</summary>
public sealed record UpdateClinRequest(
    int ClinEntryId,
    string ClinNumber,
    string? ClinDescription,
    decimal Cost,
    decimal Fee);
