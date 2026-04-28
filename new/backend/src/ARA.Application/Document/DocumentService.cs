using ARA.Application.Common;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Document;

/// <summary>Manages ARA document metadata with PDF-only and 5MB size validation.</summary>
public sealed class DocumentService : IDocumentService
{
    private const int MaxFileSizeMb = 5;
    private const long MaxFileSizeBytes = MaxFileSizeMb * 1024 * 1024;

    private readonly IDocumentRepository _documentRepository;
    private readonly ILogger<DocumentService> _logger;

    /// <summary>Initializes a new instance of <see cref="DocumentService"/>.</summary>
    public DocumentService(IDocumentRepository documentRepository, ILogger<DocumentService> logger)
    {
        _documentRepository = documentRepository;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<AraDocumentDto>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        IReadOnlyList<AraDocument> docs = await _documentRepository.GetByAraIdAsync(araId, cancellationToken);
        return docs.Select(ToDto).ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<Result<int>> CreateAsync(int araId, int uploadedByUserId, CreateDocumentRequest request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.FileName))
            return Result<int>.Failure("File name is required.");

        if (!request.FileName.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase))
            return Result<int>.Failure("Only PDF files are accepted.");

        if (request.FileSizeBytes.HasValue && request.FileSizeBytes.Value > MaxFileSizeBytes)
            return Result<int>.Failure($"File size exceeds the {MaxFileSizeMb} MB limit.");

        AraDocument document = new()
        {
            AraId = araId,
            FileName = request.FileName,
            StoragePath = request.StoragePath,
            UploadedByUserId = uploadedByUserId,
            UploadedAt = DateTime.UtcNow,
        };

        int araDocumentId = await _documentRepository.CreateAsync(document, cancellationToken);
        _logger.LogInformation("Created document record {AraDocumentId} for ARA {AraId}.", araDocumentId, araId);
        return Result<int>.Success(araDocumentId);
    }

    /// <inheritdoc/>
    public async Task<Result> DeleteAsync(int araDocumentId, CancellationToken cancellationToken = default)
    {
        await _documentRepository.DeleteAsync(araDocumentId, cancellationToken);
        _logger.LogInformation("Deleted document record {AraDocumentId}.", araDocumentId);
        return Result.Success();
    }

    private static AraDocumentDto ToDto(AraDocument d) =>
        new(d.AraDocumentId, d.AraId, d.FileName, d.StoragePath, d.UploadedByUserId, d.UploadedAt);
}
