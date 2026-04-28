namespace ARA.Application.Document;

/// <summary>
/// Payload for registering a document upload.
/// The caller is responsible for uploading the file to Azure Blob Storage and
/// providing the resulting storage path before calling this endpoint.
/// </summary>
public sealed record CreateDocumentRequest(
    string FileName,
    string StoragePath,
    long? FileSizeBytes = null);
