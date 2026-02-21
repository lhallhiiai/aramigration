using ARA.Domain.Enums;

namespace ARA.Domain.Entities;

/// <summary>
/// Represents a PDF document uploaded to support an ARA.
/// A single document may satisfy multiple document requirements simultaneously,
/// and a single requirement may be satisfied by multiple documents.
/// Only PDF format is accepted.
/// </summary>
public sealed class AraDocument
{
    /// <summary>Gets the unique identifier for this document record (primary key).</summary>
    public int AraDocumentId { get; init; }

    /// <summary>Gets the ID of the ARA this document is associated with.</summary>
    public int AraId { get; init; }

    /// <summary>Gets the original file name of the uploaded PDF.</summary>
    public string FileName { get; init; } = string.Empty;

    /// <summary>Gets the blob storage path or identifier where the file is stored.</summary>
    public string StoragePath { get; init; } = string.Empty;

    /// <summary>Gets the role of the user who uploaded this document (CA or Controller).</summary>
    public UserRole UploadedByRole { get; init; }

    /// <summary>Gets the ID of the user who uploaded this document.</summary>
    public int UploadedByUserId { get; init; }

    /// <summary>Gets the UTC timestamp when this document was uploaded.</summary>
    public DateTime UploadedAt { get; init; }
}
