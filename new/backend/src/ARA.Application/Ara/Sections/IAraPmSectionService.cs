using ARA.Application.Common;

namespace ARA.Application.Ara.Sections;

/// <summary>Manages the PM narrative section for an ARA.</summary>
public interface IAraPmSectionService
{
    /// <summary>
    /// Returns the PM section for the given ARA, or null if the PM has not yet saved it.
    /// </summary>
    Task<AraPmSectionDto?> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>Creates or updates the PM narrative section for the given ARA.</summary>
    Task<Result> SaveAsync(int araId, SaveAraPmSectionRequest request, CancellationToken cancellationToken = default);
}
