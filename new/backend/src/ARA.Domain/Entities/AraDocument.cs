namespace ARA.Domain.Entities;

/// <summary>
/// Represents a PDF document uploaded to support an ARA.
/// A single document may satisfy multiple document requirements simultaneously,
/// and a single requirement may be satisfied by multiple documents.
/// Only PDF format is accepted. File content is stored in Azure Blob Storage;
/// this record contains the metadata and storage path only.
/// Maps to the legacy <c>attachments</c> table (new name: <c>AraAttachment</c>).
/// </summary>
public sealed class AraDocument
{
    /// <summary>Gets the unique identifier for this document record (primary key). Maps to <c>AraAttachmentId</c>.</summary>
    public int AraDocumentId { get; init; }

    /// <summary>Gets the ID of the ARA this document is associated with.</summary>
    public int AraId { get; init; }

    /// <summary>Gets the original file name of the uploaded PDF.</summary>
    public string FileName { get; init; } = string.Empty;

    /// <summary>Gets the Azure Blob Storage path where the file content is stored.</summary>
    public string StoragePath { get; init; } = string.Empty;

    /// <summary>Gets the ID of the user who uploaded this document.</summary>
    public int? UploadedByUserId { get; init; }

    /// <summary>Gets the UTC timestamp when this document was uploaded.</summary>
    public DateTime UploadedAt { get; init; }
}
