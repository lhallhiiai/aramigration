namespace ARA.Application.JobTitle;

/// <summary>Job title lookup record returned to the client.</summary>
public sealed record JobTitleDto(
    int JobTitleId,
    string Title,
    string? Description,
    int? AppOrder);
