using ARA.Domain.Entities;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for ARA document upload records.
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IDocumentRepository
{
    /// <summary>Retrieves all document records associated with a given ARA.</summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<AraDocument>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>Persists a new document upload record.</summary>
    /// <param name="document">The document record to persist.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>The newly assigned AraDocumentId.</returns>
    Task<int> CreateAsync(AraDocument document, CancellationToken cancellationToken = default);

    /// <summary>Removes a document upload record by its identifier.</summary>
    /// <param name="araDocumentId">The document record primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task DeleteAsync(int araDocumentId, CancellationToken cancellationToken = default);
}
