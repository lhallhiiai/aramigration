using ARA.Application.Common;

namespace ARA.Application.Clin;

/// <summary>Manages CLIN worksheet entries for the Controller stage.</summary>
public interface IClinEntryService
{
    /// <summary>Returns all CLIN entries for the given ARA.</summary>
    Task<IReadOnlyList<ClinEntryDto>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>Adds a CLIN entry and returns the new ClinEntryId.</summary>
    Task<Result<int>> CreateAsync(int araId, CreateClinRequest request, CancellationToken cancellationToken = default);

    /// <summary>Updates Cost and Fee on an existing CLIN entry.</summary>
    Task<Result> UpdateAsync(UpdateClinRequest request, CancellationToken cancellationToken = default);

    /// <summary>Removes a CLIN entry.</summary>
    Task<Result> DeleteAsync(int clinEntryId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Returns CLIN summary totals for the given ARA, including a soft warning flag
    /// if the combined CLIN funding exceeds the ARA amount set by the PM.
    /// </summary>
    Task<ClinSummaryDto> GetSummaryAsync(int araId, CancellationToken cancellationToken = default);
}
