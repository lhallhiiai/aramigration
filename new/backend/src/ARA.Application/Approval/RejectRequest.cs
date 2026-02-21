namespace ARA.Application.Approval;

/// <summary>
/// Payload for rejecting an ARA at any workflow stage.
/// A rejection returns the ARA to Draft, increments the Revision counter,
/// and notifies all prior actors by email.
/// </summary>
public sealed record RejectRequest(
    string Comment,
    int? RejectionReasonId,
    string? RejectionAreas);
