namespace ARA.Application.Clin;

/// <summary>Payload for adding a CLIN entry to the Controller worksheet.</summary>
public sealed record CreateClinRequest(
    string ClinNumber,
    string? ClinDescription,
    decimal Cost,
    decimal Fee);
