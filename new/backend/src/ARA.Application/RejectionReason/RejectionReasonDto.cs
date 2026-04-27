namespace ARA.Application.RejectionReason;

/// <summary>
/// Data transfer object for a rejection reason code, used to populate the rejection dropdown.
/// </summary>
public sealed record RejectionReasonDto(
    int RejectionReasonId,
    string Description,
    int DisplayOrder);
