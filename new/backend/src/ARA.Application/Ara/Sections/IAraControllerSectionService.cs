using ARA.Application.Common;

namespace ARA.Application.Ara.Sections;

/// <summary>
/// Manages the Controller section for an ARA.
/// Applies to Non-Early Start ARAs only; CLIN totals are auto-calculated by the database.
/// </summary>
public interface IAraControllerSectionService
{
    /// <summary>
    /// Returns the Controller section for the given ARA, or null if the Controller has not yet saved it.
    /// </summary>
    Task<AraControllerSectionDto?> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Creates or updates the Controller section for the given ARA.
    /// <paramref name="controllerId"/> identifies the Controller completing this section.
    /// </summary>
    Task<Result> SaveAsync(int araId, int controllerId, SaveAraControllerSectionRequest request, CancellationToken cancellationToken = default);
}
