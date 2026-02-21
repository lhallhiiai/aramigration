using ARA.Domain.Entities;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for the PM narrative section of an ARA.
/// Maps to the <c>AraPmSection</c> table (legacy: <c>ara_PM</c>).
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IAraPmSectionRepository
{
    /// <summary>Retrieves the PM section for the given ARA, or null if not yet saved.</summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<AraPmSection?> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Creates or updates the PM section for the given ARA.
    /// Idempotent: safe to call on both first save and subsequent saves.
    /// </summary>
    /// <param name="section">The section data to persist.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task UpsertAsync(AraPmSection section, CancellationToken cancellationToken = default);
}
