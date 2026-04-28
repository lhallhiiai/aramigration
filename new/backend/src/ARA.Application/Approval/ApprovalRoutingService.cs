using ARA.Application.Common;
using ARA.Domain.Entities;
using ARA.Domain.Enums;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Approval;

/// <summary>
/// Implements the sequential Approval and Threshold Matrix routing engine.
/// Determines which approval steps are required for a given ARA (based on dollar amount),
/// tracks chain progression against existing approval records, resolves delegation,
/// and enforces approve_grp matching.
/// </summary>
public sealed class ApprovalRoutingService : IApprovalRoutingService
{
    private readonly IAraRepository _araRepository;
    private readonly IApprovalMatrixRepository _matrixRepository;
    private readonly IApprovalRecordRepository _approvalRecordRepository;
    private readonly IUserRepository _userRepository;
    private readonly IDelegationRepository _delegationRepository;
    private readonly ILogger<ApprovalRoutingService> _logger;

    /// <summary>Initializes a new instance of <see cref="ApprovalRoutingService"/>.</summary>
    public ApprovalRoutingService(
        IAraRepository araRepository,
        IApprovalMatrixRepository matrixRepository,
        IApprovalRecordRepository approvalRecordRepository,
        IUserRepository userRepository,
        IDelegationRepository delegationRepository,
        ILogger<ApprovalRoutingService> logger)
    {
        _araRepository = araRepository;
        _matrixRepository = matrixRepository;
        _approvalRecordRepository = approvalRecordRepository;
        _userRepository = userRepository;
        _delegationRepository = delegationRepository;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<Result<ApprovalStepResult?>> GetNextRequiredStepAsync(
        int araId, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result<ApprovalStepResult?>.Failure($"ARA {araId} not found.");
        if (ara.Status != AraStatus.PendingApproval)
            return Result<ApprovalStepResult?>.Failure("ARA must be in PendingApproval status.");

        IReadOnlyList<ApprovalStepResult> chain = await BuildChainAsync(ara, cancellationToken);

        ApprovalStepResult? nextStep = chain.FirstOrDefault(step => !step.IsCompleted);
        return Result<ApprovalStepResult?>.Success(nextStep);
    }

    /// <inheritdoc/>
    public async Task<Result<ApprovalAuthorization>> AuthorizeApproverAsync(
        int araId, int actingUserId, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result<ApprovalAuthorization>.Failure($"ARA {araId} not found.");
        if (ara.Status != AraStatus.PendingApproval)
            return Result<ApprovalAuthorization>.Failure("ARA must be in PendingApproval status.");

        IReadOnlyList<ApprovalStepResult> chain = await BuildChainAsync(ara, cancellationToken);
        ApprovalStepResult? currentStep = chain.FirstOrDefault(step => !step.IsCompleted);
        if (currentStep is null)
            return Result<ApprovalAuthorization>.Failure("All approval steps are already complete.");

        User? actingUser = await _userRepository.GetByIdAsync(actingUserId, cancellationToken);
        if (actingUser is null || actingUser.IsInactive)
            return Result<ApprovalAuthorization>.Failure("Acting user not found or inactive.");

        IReadOnlyList<ApprovalRecord> existingRecords =
            await _approvalRecordRepository.GetByAraIdAndRevisionAsync(araId, ara.Revision, cancellationToken);

        ApprovalAuthorization? directAuth = TryDirectAuthorization(
            actingUser, currentStep, ara.Division, existingRecords);
        if (directAuth is not null)
            return Result<ApprovalAuthorization>.Success(directAuth);

        ApprovalAuthorization? delegatedAuth = await TryDelegatedAuthorizationAsync(
            actingUser, currentStep, ara.Division, existingRecords, cancellationToken);
        if (delegatedAuth is not null)
            return Result<ApprovalAuthorization>.Success(delegatedAuth);

        return Result<ApprovalAuthorization>.Failure(
            $"User {actingUserId} is not authorized to act on step {currentStep.SequenceOrder} ({currentStep.RoleName}).");
    }

    /// <inheritdoc/>
    public async Task<Result<IReadOnlyList<ApprovalStepResult>>> GetRequiredChainAsync(
        int araId, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result<IReadOnlyList<ApprovalStepResult>>.Failure($"ARA {araId} not found.");

        IReadOnlyList<ApprovalStepResult> chain = await BuildChainAsync(ara, cancellationToken);
        return Result<IReadOnlyList<ApprovalStepResult>>.Success(chain);
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private async Task<IReadOnlyList<ApprovalStepResult>> BuildChainAsync(
        Domain.Entities.Ara ara, CancellationToken cancellationToken)
    {
        IReadOnlyList<ApprovalMatrixEntry> requiredEntries =
            await _matrixRepository.GetRequiredEntriesForAmountAsync(ara.AmountTotal, cancellationToken);

        IReadOnlyList<ApprovalRecord> completedRecords =
            await _approvalRecordRepository.GetByAraIdAndRevisionAsync(ara.AraId, ara.Revision, cancellationToken);

        HashSet<int> completedSequences = completedRecords
            .Where(r => r.Action == ApprovalActionType.Approve || r.Action == ApprovalActionType.Review)
            .Select(r => r.SequenceOrder)
            .ToHashSet();

        List<ApprovalStepResult> chain = requiredEntries
            .Select(entry => new ApprovalStepResult(
                entry.SequenceOrder,
                entry.RoleName,
                entry.JobTitleId,
                entry.RequiredAction,
                entry.MinimumAmount,
                completedSequences.Contains(entry.SequenceOrder)))
            .ToList();

        return chain.AsReadOnly();
    }

    private static ApprovalAuthorization? TryDirectAuthorization(
        User actingUser,
        ApprovalStepResult currentStep,
        string? araDivision,
        IReadOnlyList<ApprovalRecord> existingRecords)
    {
        if (actingUser.JobTitleId != currentStep.JobTitleId)
            return null;

        if (!DivisionMatchesApprovalGroups(araDivision, actingUser.ApprovalGroups))
            return null;

        if (HasAlreadyActedAtDifferentStep(actingUser.UserId, currentStep.SequenceOrder, existingRecords))
            return null;

        return new ApprovalAuthorization(
            IsAuthorized: true,
            SequenceOrder: currentStep.SequenceOrder,
            RequiredAction: currentStep.RequiredAction,
            ActingAsUserId: actingUser.UserId,
            ActingAsJobTitleId: actingUser.JobTitleId,
            IsDelegated: false);
    }

    private async Task<ApprovalAuthorization?> TryDelegatedAuthorizationAsync(
        User actingUser,
        ApprovalStepResult currentStep,
        string? araDivision,
        IReadOnlyList<ApprovalRecord> existingRecords,
        CancellationToken cancellationToken)
    {
        IReadOnlyList<Domain.Entities.Delegation> delegations =
            await _delegationRepository.GetActiveDelegationsForDelegateeAsync(actingUser.UserId, cancellationToken);

        foreach (Domain.Entities.Delegation delegation in delegations)
        {
            User? delegator = await _userRepository.GetByIdAsync(delegation.DelegatorUserId, cancellationToken);
            if (delegator is null || delegator.IsInactive)
                continue;

            if (delegator.JobTitleId != currentStep.JobTitleId)
                continue;

            if (!DivisionMatchesApprovalGroups(araDivision, delegator.ApprovalGroups))
                continue;

            if (HasAlreadyActedAtDifferentStep(delegator.UserId, currentStep.SequenceOrder, existingRecords))
                continue;

            if (HasAlreadyActedAtDifferentStep(actingUser.UserId, currentStep.SequenceOrder, existingRecords))
                continue;

            _logger.LogInformation(
                "User {DelegateeId} authorized via delegation from user {DelegatorId} for step {Step}.",
                actingUser.UserId, delegator.UserId, currentStep.SequenceOrder);

            return new ApprovalAuthorization(
                IsAuthorized: true,
                SequenceOrder: currentStep.SequenceOrder,
                RequiredAction: currentStep.RequiredAction,
                ActingAsUserId: delegator.UserId,
                ActingAsJobTitleId: delegator.JobTitleId,
                IsDelegated: true);
        }

        return null;
    }

    private static bool HasAlreadyActedAtDifferentStep(
        int userId, int currentSequenceOrder, IReadOnlyList<ApprovalRecord> existingRecords)
    {
        return existingRecords.Any(r =>
            (r.ApproverId == userId || r.DelegatorUserId == userId)
            && r.SequenceOrder != currentSequenceOrder
            && (r.Action == ApprovalActionType.Approve || r.Action == ApprovalActionType.Review));
    }

    /// <summary>
    /// Checks whether the ARA's division is contained in the user's comma-separated
    /// <c>approve_grp</c> list. Only <c>approve_grp</c> is used for routing (per product owner).
    /// </summary>
    /// <inheritdoc cref="DivisionMatchesApprovalGroups(string?, string?)"/>
    public static bool DivisionMatchesApprovalGroups(string? araDivision, string? approvalGroups)
    {
        if (string.IsNullOrWhiteSpace(araDivision) || string.IsNullOrWhiteSpace(approvalGroups))
            return false;

        string[] groups = approvalGroups.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        return groups.Contains(araDivision, StringComparer.OrdinalIgnoreCase);
    }
}
