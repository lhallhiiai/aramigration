namespace ARA.Api.Controllers;

/// <summary>
/// DTO for environment information returned to the frontend.
/// </summary>
public sealed record EnvironmentInfoDto
{
    /// <summary>The environment name (Development, Test, Production).</summary>
    public required string Name { get; init; }
}
