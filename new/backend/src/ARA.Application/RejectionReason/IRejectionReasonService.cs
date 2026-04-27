namespace ARA.Application.RejectionReason;

/// <summary>
/// Read-only lookup service for rejection reason codes.
/// </summary>
public interface IRejectionReasonService
{
    /// <summary>Returns all active rejection reason codes ordered by display order.</summary>
    Task<IReadOnlyList<RejectionReasonDto>> GetAllActiveAsync(CancellationToken cancellationToken = default);
}
