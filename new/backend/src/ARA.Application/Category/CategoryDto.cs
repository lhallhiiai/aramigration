namespace ARA.Application.Category;

/// <summary>Risk category lookup record returned to the client.</summary>
public sealed record CategoryDto(
    int CategoryId,
    string CategoryName,
    int RiskLevel,
    string? Color);
