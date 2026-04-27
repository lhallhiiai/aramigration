using ARA.Application.Approval;
using ARA.Application.Common;
using ARA.Domain.Enums;

namespace ARA.Application.Ara;

/// <summary>
/// Manages ARA lifecycle: reads, creates, updates, and all workflow transitions.
/// Controllers are thin; all business rules live here.
/// </summary>
public interface IAraService
{
    // ── Reads ──────────────────────────────────────────────────────────────────

    /// <summary>Returns a full ARA detail record, or null if not found.</summary>
    Task<AraDetailDto?> GetByIdAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Returns ARAs currently awaiting action from the given user.
    /// Drives the My Action List on the landing page.
    /// </summary>
    Task<IReadOnlyList<AraListItemDto>> GetPendingForUserAsync(int userId, CancellationToken cancellationToken = default);

    /// <summary>Returns all active (non-terminal) ARAs. Drives the See All ARAs view.</summary>
    Task<IReadOnlyList<AraListItemDto>> GetAllActiveAsync(CancellationToken cancellationToken = default);

    /// <summary>Returns Exported and Negated ARAs accessible via the Archived menu.</summary>
    Task<IReadOnlyList<AraListItemDto>> GetArchivedAsync(CancellationToken cancellationToken = default);

    /// <summary>Returns ARAs filtered by status. Drives Dashboard grouped-status views.</summary>
    Task<IReadOnlyList<AraListItemDto>> GetByStatusAsync(AraStatus status, CancellationToken cancellationToken = default);

    /// <summary>Searches ARAs by partial or full ARA ID or JAMIS ID. Drives Quick Search.</summary>
    Task<IReadOnlyList<AraListItemDto>> SearchAsync(string searchTerm, CancellationToken cancellationToken = default);

    /// <summary>Returns active ARAs sorted by expiration date. Drives the Dashboard expirations view.</summary>
    Task<IReadOnlyList<AraListItemDto>> GetUpcomingExpirationsAsync(CancellationToken cancellationToken = default);

    // ── Writes ─────────────────────────────────────────────────────────────────

    /// <summary>
    /// Creates a new ARA in Draft status and returns the new AraId.
    /// <paramref name="createdByUserId"/> is the authenticated caller's UserId.
    /// </summary>
    Task<Result<int>> CreateAsync(CreateAraRequest request, int createdByUserId, CancellationToken cancellationToken = default);

    /// <summary>Persists changes to an existing ARA's editable fields.</summary>
    Task<Result> UpdateAsync(UpdateAraRequest request, CancellationToken cancellationToken = default);

    // ── Workflow transitions ────────────────────────────────────────────────────

    /// <summary>
    /// PM signs and submits the ARA. Transitions Draft → PendingContractAdministrator.
    /// Only the assigned PM may call this.
    /// </summary>
    Task<Result> SubmitByPmAsync(int araId, int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// CA submits the ARA forward. Transitions PendingContractAdministrator → PendingController.
    /// Only the assigned CA may call this.
    /// </summary>
    Task<Result> SubmitByCaAsync(int araId, int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Controller submits the ARA for approval. Transitions PendingController → PendingApproval.
    /// Only the assigned Controller may call this.
    /// </summary>
    Task<Result> SubmitByControllerAsync(int araId, int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Approver acts on the ARA at the current step of the Approval and Threshold Matrix.
    /// The routing engine determines the required action (Approve or Review), validates
    /// authorization including delegation, and advances the chain. Transitions to Approved
    /// when all required steps are complete.
    /// </summary>
    Task<Result> ApproveAsync(int araId, int approverId, string? comment, CancellationToken cancellationToken = default);

    /// <summary>
    /// Rejects the ARA at any workflow stage (CA, Controller, or Approver).
    /// Returns the ARA to Draft, increments Revision, and records the rejection log entry.
    /// </summary>
    Task<Result> RejectAsync(int araId, int userId, RejectRequest request, CancellationToken cancellationToken = default);

    /// <summary>
    /// PM cancels the ARA. Only the assigned PM may cancel; applies to non-terminal ARAs.
    /// </summary>
    Task<Result> CancelAsync(int araId, int userId, CancellationToken cancellationToken = default);

    /// <summary>
    /// CA negates an Approved or Exported ARA after a contract modification is received.
    /// Transitions to Negated. Only the assigned CA may call this.
    /// </summary>
    Task<Result> NegateAsync(int araId, int userId, CancellationToken cancellationToken = default);
}
