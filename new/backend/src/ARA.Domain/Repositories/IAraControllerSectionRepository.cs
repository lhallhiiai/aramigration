using ARA.Domain.Entities;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for the Controller section of an ARA.
/// Maps to the <c>AraControllerSection</c> table (legacy: <c>ara_con</c>).
/// TotalCost and TotalFee are auto-calculated by the stored procedure from CLIN entries.
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IAraControllerSectionRepository
{
    /// <summary>Retrieves the Controller section for the given ARA, or null if not yet saved.</summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<AraControllerSection?> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Creates or updates the Controller section for the given ARA.
    /// The stored procedure recalculates TotalCost and TotalFee from current CLIN entries.
    /// Idempotent: safe to call on both first save and subsequent saves.
    /// </summary>
    /// <param name="section">The section data to persist.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task UpsertAsync(AraControllerSection section, CancellationToken cancellationToken = default);
}
