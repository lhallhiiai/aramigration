namespace ARA.Application.Document;

/// <summary>Document upload record returned to the client.</summary>
public sealed record AraDocumentDto(
    int AraDocumentId,
    int AraId,
    string FileName,
    string StoragePath,
    int? UploadedByUserId,
    DateTime UploadedAt);
