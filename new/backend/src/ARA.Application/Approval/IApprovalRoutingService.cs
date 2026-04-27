using ARA.Application.Common;

namespace ARA.Application.Approval;

/// <summary>
/// Determines the next required approval step for an ARA and authorizes users
/// to act on the current step, including delegation resolution.
/// This is the core engine driving the sequential Approval and Threshold Matrix.
/// </summary>
public interface IApprovalRoutingService
{
    /// <summary>
    /// Determines the next required approval step for an ARA, or null if all
    /// approvals for the current revision are complete.
    /// </summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    /// <returns>
    /// The next incomplete <see cref="ApprovalStepResult"/>, or null if the ARA
    /// has satisfied all required approval steps.
    /// </returns>
    Task<Result<ApprovalStepResult?>> GetNextRequiredStepAsync(int araId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Checks whether the specified user is authorized to act on the current
    /// approval step for the given ARA, including delegation checks.
    /// </summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="actingUserId">The user attempting to take the approval action.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<Result<ApprovalAuthorization>> AuthorizeApproverAsync(int araId, int actingUserId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Returns the full required approval chain for an ARA with completion status
    /// for each step. Used for the Approval Cycle display and System Information page.
    /// </summary>
    /// <param name="araId">The ARA primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<Result<IReadOnlyList<ApprovalStepResult>>> GetRequiredChainAsync(int araId, CancellationToken cancellationToken = default);
}
