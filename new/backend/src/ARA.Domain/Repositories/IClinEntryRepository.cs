using ARA.Domain.Entities;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for CLIN Worksheet entries.
/// Applies to Non-Early Start ARAs only; never called for Early Start ARAs.
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IClinEntryRepository
{
    /// <summary>Retrieves all CLIN entries for a given ARA.</summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<ClinEntry>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Persists a new CLIN entry and returns the assigned ClinEntryId.
    /// Callers must ensure the ClinNumber has not already been used on this ARA.
    /// </summary>
    /// <param name="entry">The CLIN entry to persist.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>The newly assigned ClinEntryId.</returns>
    Task<int> CreateAsync(ClinEntry entry, CancellationToken cancellationToken = default);

    /// <summary>Updates the Cost and Fee values on an existing CLIN entry.</summary>
    /// <param name="entry">The updated CLIN entry data.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task UpdateAsync(ClinEntry entry, CancellationToken cancellationToken = default);

    /// <summary>Removes a CLIN entry by its identifier.</summary>
    /// <param name="clinEntryId">The CLIN entry primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task DeleteAsync(int clinEntryId, CancellationToken cancellationToken = default);
}
