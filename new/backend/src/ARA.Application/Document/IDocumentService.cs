using ARA.Application.Common;

namespace ARA.Application.Document;

/// <summary>Manages PDF document uploads attached to an ARA.</summary>
public interface IDocumentService
{
    /// <summary>Returns all document records for the given ARA.</summary>
    Task<IReadOnlyList<AraDocumentDto>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Persists a new document metadata record after the file has been uploaded to Blob Storage.
    /// Returns the new AraDocumentId.
    /// </summary>
    Task<Result<int>> CreateAsync(int araId, int uploadedByUserId, CreateDocumentRequest request, CancellationToken cancellationToken = default);

    /// <summary>Removes a document metadata record by its identifier.</summary>
    Task<Result> DeleteAsync(int araDocumentId, CancellationToken cancellationToken = default);
}
