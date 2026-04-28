using ARA.Application.Approval;
using ARA.Application.Common;
using ARA.Application.Email;
using ARA.Domain.Entities;
using ARA.Domain.Enums;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Ara;

/// <summary>
/// Manages ARA lifecycle including CRUD and all workflow transitions.
/// All business rule failures are returned as <see cref="Result"/> failures; exceptions are never thrown for business rules.
/// </summary>
/// <remarks>
/// The <c>ApplyUpdate</c> helper below copies every Ara property and exceeds 20 lines.
/// This is an inherent consequence of <c>Ara</c> being a sealed class with init-only properties
/// (which prevents C# <c>with</c>-expression syntax). A future refactor converting <c>Ara</c>
/// to a <c>record</c> would reduce this to a single <c>with</c> expression.
/// </remarks>
public sealed class AraService : IAraService
{
    private readonly IAraRepository _araRepository;
    private readonly IApprovalRecordRepository _approvalRepository;
    private readonly IApprovalRoutingService _routingService;
    private readonly IUserRepository _userRepository;
    private readonly IEmailService _emailService;
    private readonly ILogger<AraService> _logger;

    /// <summary>Initializes a new instance of <see cref="AraService"/>.</summary>
    public AraService(
        IAraRepository araRepository,
        IApprovalRecordRepository approvalRepository,
        IApprovalRoutingService routingService,
        IUserRepository userRepository,
        IEmailService emailService,
        ILogger<AraService> logger)
    {
        _araRepository      = araRepository;
        _approvalRepository = approvalRepository;
        _routingService     = routingService;
        _userRepository     = userRepository;
        _emailService       = emailService;
        _logger             = logger;
    }

    // ── Reads ──────────────────────────────────────────────────────────────────

    /// <inheritdoc/>
    public async Task<AraDetailDto?> GetByIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        return ara is null ? null : ToDetail(ara);
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<AraListItemDto>> GetPendingForUserAsync(int userId, CancellationToken cancellationToken = default)
    {
        IReadOnlyList<Domain.Entities.Ara> aras = await _araRepository.GetPendingForUserAsync(userId, cancellationToken);
        return aras.Select(ToListItem).ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<AraListItemDto>> GetAllActiveAsync(CancellationToken cancellationToken = default)
    {
        IReadOnlyList<Domain.Entities.Ara> aras = await _araRepository.GetAllActiveAsync(cancellationToken);
        return aras.Select(ToListItem).ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<AraListItemDto>> GetArchivedAsync(CancellationToken cancellationToken = default)
    {
        IReadOnlyList<Domain.Entities.Ara> aras = await _araRepository.GetArchivedAsync(cancellationToken);
        return aras.Select(ToListItem).ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<AraListItemDto>> GetByStatusAsync(AraStatus status, CancellationToken cancellationToken = default)
    {
        IReadOnlyList<Domain.Entities.Ara> aras = await _araRepository.GetByStatusAsync(status, cancellationToken);
        return aras.Select(ToListItem).ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<AraListItemDto>> SearchAsync(string searchTerm, CancellationToken cancellationToken = default)
    {
        IReadOnlyList<Domain.Entities.Ara> aras = await _araRepository.SearchByIdAsync(searchTerm, cancellationToken);
        return aras.Select(ToListItem).ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<AraListItemDto>> GetUpcomingExpirationsAsync(CancellationToken cancellationToken = default)
    {
        IReadOnlyList<Domain.Entities.Ara> aras = await _araRepository.GetUpcomingExpirationsAsync(cancellationToken);
        return aras.Select(ToListItem).ToList().AsReadOnly();
    }

    // ── Writes ─────────────────────────────────────────────────────────────────

    /// <inheritdoc/>
    public async Task<Result<int>> CreateAsync(CreateAraRequest request, int createdByUserId, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara ara = new()
        {
            CategoryId              = request.CategoryId,
            StatusId                = (int)AraStatus.Draft,
            CreatedByUserId         = createdByUserId,
            ProgramManagerId        = request.ProgramManagerId,
            ContractAdministratorId = request.ContractAdministratorId,
            ControllerId            = request.ControllerId,
            OpsVpUserId             = request.OpsVpUserId,
            Division                = request.Division,
            ContractNumber          = request.ContractNumber,
            DeliveryOrderNumber     = request.DeliveryOrderNumber,
            ContractType            = request.ContractType,
            OmsNumber               = request.OmsNumber,
            Title                   = request.Title,
            CustomerName            = request.CustomerName,
            AmountTotal             = request.AmountTotal,
            AmountRequested         = request.AmountRequested,
            TotalAnticipated        = request.TotalAnticipated,
            PercentAnticipated      = request.PercentAnticipated,
            RevenueDescriptionId    = request.RevenueDescriptionId,
            IsEarlyStart            = request.IsEarlyStart,
            EarlyStartReasonId      = request.EarlyStartReasonId,
            EarlyStartReasonOther   = request.EarlyStartReasonOther,
            Company                 = request.Company,
            IsEac                   = request.IsEac,
            StartDate               = request.StartDate,
            ExpirationDate          = request.ExpirationDate,
        };

        int araId = await _araRepository.CreateAsync(ara, cancellationToken);
        _logger.LogInformation("Created ARA {AraId} by user {UserId}.", araId, createdByUserId);
        return Result<int>.Success(araId);
    }

    /// <inheritdoc/>
    public async Task<Result> UpdateAsync(UpdateAraRequest request, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? existing = await _araRepository.GetByIdAsync(request.AraId, cancellationToken);
        if (existing is null)
            return Result.Failure($"ARA {request.AraId} not found.");

        await _araRepository.UpdateAsync(ApplyUpdate(existing, request), cancellationToken);
        _logger.LogInformation("Updated ARA {AraId}.", request.AraId);
        return Result.Success();
    }

    // ── Workflow transitions ────────────────────────────────────────────────────

    /// <inheritdoc/>
    public async Task<Result> SubmitByPmAsync(int araId, int userId, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result.Failure($"ARA {araId} not found.");
        if (ara.Status != AraStatus.Draft)
            return Result.Failure("ARA must be in Draft status to submit.");
        if (ara.ProgramManagerId != userId)
            return Result.Failure("Only the assigned Program Manager may submit this ARA.");

        await _araRepository.UpdateStatusAsync(araId, AraStatus.PendingContractAdministrator, ara.Revision, cancellationToken: cancellationToken);
        _logger.LogInformation("ARA {AraId} submitted by PM {UserId}.", araId, userId);

        await SendEmailSafeAsync(async () =>
        {
            User? pm = await _userRepository.GetByIdAsync(userId, cancellationToken);
            User? ca = await _userRepository.GetByIdAsync(ara.ContractAdministratorId, cancellationToken);
            if (pm is not null && ca is not null)
                await _emailService.SendAsync(AraEmailBuilder.PmSubmitted(ara, pm, ca), cancellationToken);
        }, araId, "PmSubmitted");

        return Result.Success();
    }

    /// <inheritdoc/>
    public async Task<Result> SubmitByCaAsync(int araId, int userId, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result.Failure($"ARA {araId} not found.");
        if (ara.Status != AraStatus.PendingContractAdministrator)
            return Result.Failure("ARA must be in PendingContractAdministrator status to submit.");
        if (ara.ContractAdministratorId != userId)
            return Result.Failure("Only the assigned Contract Administrator may submit this ARA.");

        await _araRepository.UpdateStatusAsync(araId, AraStatus.PendingController, ara.Revision, cancellationToken: cancellationToken);
        _logger.LogInformation("ARA {AraId} submitted by CA {UserId}.", araId, userId);

        await SendEmailSafeAsync(async () =>
        {
            User? ca = await _userRepository.GetByIdAsync(userId, cancellationToken);
            User? controller = await _userRepository.GetByIdAsync(ara.ControllerId, cancellationToken);
            if (ca is not null && controller is not null)
                await _emailService.SendAsync(AraEmailBuilder.CaSubmitted(ara, ca, controller), cancellationToken);
        }, araId, "CaSubmitted");

        return Result.Success();
    }

    /// <inheritdoc/>
    public async Task<Result> SubmitByControllerAsync(int araId, int userId, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result.Failure($"ARA {araId} not found.");
        if (ara.Status != AraStatus.PendingController)
            return Result.Failure("ARA must be in PendingController status to submit.");
        if (ara.ControllerId != userId)
            return Result.Failure("Only the assigned Controller may submit this ARA.");

        await _araRepository.UpdateStatusAsync(araId, AraStatus.PendingApproval, ara.Revision, cancellationToken: cancellationToken);
        _logger.LogInformation("ARA {AraId} submitted by Controller {UserId}.", araId, userId);

        await SendEmailSafeAsync(async () =>
        {
            User? controller = await _userRepository.GetByIdAsync(userId, cancellationToken);
            if (controller is not null)
            {
                Result<ApprovalStepResult?> nextStep = await _routingService.GetNextRequiredStepAsync(araId, cancellationToken);
                string approverEmail = "first-approver@pending.lookup";
                await _emailService.SendAsync(AraEmailBuilder.ControllerSubmitted(ara, controller, approverEmail), cancellationToken);
            }
        }, araId, "ControllerSubmitted");

        return Result.Success();
    }

    /// <inheritdoc/>
    public async Task<Result> ApproveAsync(int araId, int approverId, string? comment, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result.Failure($"ARA {araId} not found.");
        if (ara.Status != AraStatus.PendingApproval)
            return Result.Failure("ARA must be in PendingApproval status to approve.");

        Result<ApprovalAuthorization> authResult =
            await _routingService.AuthorizeApproverAsync(araId, approverId, cancellationToken);
        if (authResult.IsFailure)
            return Result.Failure(authResult.Error!);

        ApprovalAuthorization auth = authResult.Value!;

        ApprovalRecord record = new()
        {
            AraId            = araId,
            ApproverId       = approverId,
            JobTitleId       = auth.ActingAsJobTitleId,
            Action           = auth.RequiredAction,
            AraRevision      = ara.Revision,
            Comment          = comment,
            SequenceOrder    = auth.SequenceOrder,
            DelegatorUserId  = auth.IsDelegated ? auth.ActingAsUserId : null,
        };
        await _approvalRepository.CreateAsync(record, cancellationToken);

        Result<ApprovalStepResult?> nextStepResult =
            await _routingService.GetNextRequiredStepAsync(araId, cancellationToken);

        if (nextStepResult.IsSuccess && nextStepResult.Value is null)
        {
            await _araRepository.UpdateStatusAsync(araId, AraStatus.Approved, ara.Revision, cancellationToken: cancellationToken);
            _logger.LogInformation("ARA {AraId} fully approved. Final action by user {ApproverId} at step {Step}.",
                araId, approverId, auth.SequenceOrder);
        }
        else
        {
            _logger.LogInformation("ARA {AraId} {Action} by user {ApproverId} at step {Step}. Next step pending.",
                araId, auth.RequiredAction, approverId, auth.SequenceOrder);
        }

        return Result.Success();
    }

    /// <inheritdoc/>
    public async Task<Result> RejectAsync(int araId, int userId, RejectRequest request, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result.Failure($"ARA {araId} not found.");

        int sequenceOrder = 0;
        int? delegatorUserId = null;

        if (ara.Status == AraStatus.PendingContractAdministrator && ara.ContractAdministratorId == userId)
        {
            sequenceOrder = 2;
        }
        else if (ara.Status == AraStatus.PendingController && ara.ControllerId == userId)
        {
            sequenceOrder = 3;
        }
        else if (ara.Status == AraStatus.PendingApproval)
        {
            Result<ApprovalAuthorization> authResult =
                await _routingService.AuthorizeApproverAsync(araId, userId, cancellationToken);
            if (authResult.IsFailure)
                return Result.Failure($"Cannot reject: {authResult.Error}");

            ApprovalAuthorization auth = authResult.Value!;
            sequenceOrder = auth.SequenceOrder;
            delegatorUserId = auth.IsDelegated ? auth.ActingAsUserId : null;
        }
        else
        {
            return Result.Failure("Cannot reject: ARA is not in a rejectable state for this user.");
        }

        ApprovalRecord record = new()
        {
            AraId             = araId,
            ApproverId        = userId,
            Action            = ApprovalActionType.Reject,
            AraRevision       = ara.Revision,
            Comment           = request.Comment,
            RejectionReasonId = request.RejectionReasonId,
            RejectionAreas    = request.RejectionAreas,
            SequenceOrder     = sequenceOrder,
            DelegatorUserId   = delegatorUserId,
        };
        await _approvalRepository.CreateAsync(record, cancellationToken);
        await _araRepository.UpdateStatusAsync(araId, AraStatus.Draft, ara.Revision + 1, cancellationToken: cancellationToken);
        _logger.LogInformation("ARA {AraId} rejected by user {UserId} at step {Step}. New revision: {Revision}.",
            araId, userId, sequenceOrder, ara.Revision + 1);

        await SendEmailSafeAsync(async () =>
        {
            User? rejector = await _userRepository.GetByIdAsync(userId, cancellationToken);
            if (rejector is not null)
            {
                string priorEmails = await CollectPriorActorEmailsAsync(ara, cancellationToken);
                await _emailService.SendAsync(AraEmailBuilder.Rejected(ara, rejector, priorEmails, request.Comment), cancellationToken);
            }
        }, araId, "Rejected");

        return Result.Success();
    }

    /// <inheritdoc/>
    public async Task<Result> CancelAsync(int araId, int userId, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result.Failure($"ARA {araId} not found.");
        if (ara.ProgramManagerId != userId)
            return Result.Failure("Only the assigned Program Manager may cancel this ARA.");

        AraStatus[] terminalStatuses = [AraStatus.Approved, AraStatus.Exported, AraStatus.Expired, AraStatus.Negated, AraStatus.Cancelled];
        if (terminalStatuses.Contains(ara.Status))
            return Result.Failure($"ARA cannot be cancelled from status {ara.Status}.");

        await _araRepository.UpdateStatusAsync(araId, AraStatus.Cancelled, ara.Revision, cancelledAt: DateTime.UtcNow, cancellationToken: cancellationToken);
        _logger.LogInformation("ARA {AraId} cancelled by PM {UserId}.", araId, userId);

        await SendEmailSafeAsync(async () =>
        {
            User? pm = await _userRepository.GetByIdAsync(userId, cancellationToken);
            User? ca = await _userRepository.GetByIdAsync(ara.ContractAdministratorId, cancellationToken);
            if (pm is not null && ca is not null)
            {
                string recipients = $"{pm.Email};{ca.Email}";
                await _emailService.SendAsync(AraEmailBuilder.ARACancelled(ara, pm, recipients), cancellationToken);
            }
        }, araId, "Cancelled");

        return Result.Success();
    }

    /// <inheritdoc/>
    public async Task<Result> NegateAsync(int araId, int userId, CancellationToken cancellationToken = default)
    {
        Domain.Entities.Ara? ara = await _araRepository.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return Result.Failure($"ARA {araId} not found.");
        if (ara.ContractAdministratorId != userId)
            return Result.Failure("Only the assigned Contract Administrator may negate this ARA.");
        if (ara.Status != AraStatus.Approved && ara.Status != AraStatus.Exported)
            return Result.Failure("Only Approved or Exported ARAs may be negated.");

        await _araRepository.UpdateStatusAsync(araId, AraStatus.Negated, ara.Revision, negatedAt: DateTime.UtcNow, cancellationToken: cancellationToken);
        _logger.LogInformation("ARA {AraId} negated by CA {UserId}.", araId, userId);

        await SendEmailSafeAsync(async () =>
        {
            User? ca = await _userRepository.GetByIdAsync(userId, cancellationToken);
            if (ca is not null)
            {
                string partyEmails = await CollectPriorActorEmailsAsync(ara, cancellationToken);
                await _emailService.SendAsync(AraEmailBuilder.ARANegated(ara, ca, partyEmails), cancellationToken);
            }
        }, araId, "Negated");

        return Result.Success();
    }

    // ── Private email helpers ──────────────────────────────────────────────────

    /// <summary>
    /// Executes an email-sending action without allowing email failures to break the workflow.
    /// Failures are logged but not propagated.
    /// </summary>
    private async Task SendEmailSafeAsync(Func<Task> emailAction, int araId, string eventName)
    {
        try
        {
            await emailAction();
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to send {EventName} email for ARA {AraId}. Workflow continues.", eventName, araId);
        }
    }

    /// <summary>
    /// Collects email addresses of all users who have acted on the ARA (PM, CA, Controller,
    /// and any prior approvers for the current revision).
    /// </summary>
    private async Task<string> CollectPriorActorEmailsAsync(Domain.Entities.Ara ara, CancellationToken cancellationToken)
    {
        HashSet<string> emails = new(StringComparer.OrdinalIgnoreCase);

        User? pm = await _userRepository.GetByIdAsync(ara.ProgramManagerId, cancellationToken);
        if (pm is not null) emails.Add(pm.Email);

        User? ca = await _userRepository.GetByIdAsync(ara.ContractAdministratorId, cancellationToken);
        if (ca is not null) emails.Add(ca.Email);

        User? controller = await _userRepository.GetByIdAsync(ara.ControllerId, cancellationToken);
        if (controller is not null) emails.Add(controller.Email);

        IReadOnlyList<ApprovalRecord> records =
            await _approvalRepository.GetByAraIdAndRevisionAsync(ara.AraId, ara.Revision, cancellationToken);
        foreach (ApprovalRecord record in records)
        {
            if (record.ApproverId is null) continue;
            User? approver = await _userRepository.GetByIdAsync(record.ApproverId.Value, cancellationToken);
            if (approver is not null) emails.Add(approver.Email);
        }

        return string.Join(";", emails);
    }

    // ── Private mapping helpers ────────────────────────────────────────────────

    private static AraListItemDto ToListItem(Domain.Entities.Ara a) =>
        new(a.AraId, a.Reference, a.Revision, a.CategoryId, a.StatusId,
            a.Status, a.RiskCategory, a.Title, a.ContractNumber,
            a.OmsNumber, a.AmountTotal, a.IsEarlyStart, a.ExpirationDate,
            a.CreatedAt, a.ProgramManagerId, a.ContractAdministratorId, a.ControllerId);

    private static AraDetailDto ToDetail(Domain.Entities.Ara a) =>
        new(a.AraId, a.Reference, a.Revision, a.CategoryId, a.RiskCategory,
            a.StatusId, a.Status, a.CreatedByUserId, a.ProgramManagerId,
            a.ContractAdministratorId, a.ControllerId, a.OpsVpUserId,
            a.JamisId, a.Division, a.ContractNumber, a.DeliveryOrderNumber,
            a.ContractType, a.OmsNumber, a.Title, a.CustomerName,
            a.AmountTotal, a.AmountRequested, a.TotalAnticipated,
            a.PercentAnticipated, a.RevenueDescriptionId, a.IsEarlyStart,
            a.EarlyStartReasonId, a.EarlyStartReasonOther, a.Company,
            a.IsEac, a.StartDate, a.ExpirationDate, a.CreatedAt,
            a.UpdatedAt, a.ExportedAt, a.NegatedAt, a.CancelledAt);

    // Flagged: this method exceeds 20 lines because Ara is a sealed class with init-only
    // properties. Converting Ara to a record would reduce this to a single with-expression.
    private static Domain.Entities.Ara ApplyUpdate(Domain.Entities.Ara existing, UpdateAraRequest r) =>
        new()
        {
            AraId                   = existing.AraId,
            CategoryId              = r.CategoryId,
            StatusId                = existing.StatusId,
            CreatedByUserId         = existing.CreatedByUserId,
            ProgramManagerId        = r.ProgramManagerId,
            ContractAdministratorId = r.ContractAdministratorId,
            ControllerId            = r.ControllerId,
            OpsVpUserId             = r.OpsVpUserId,
            Reference               = r.Reference,
            JamisId                 = r.JamisId,
            Division                = r.Division,
            ContractNumber          = r.ContractNumber,
            DeliveryOrderNumber     = r.DeliveryOrderNumber,
            ContractType            = r.ContractType,
            OmsNumber               = r.OmsNumber,
            Title                   = r.Title,
            CustomerName            = r.CustomerName,
            AmountTotal             = r.AmountTotal,
            AmountRequested         = r.AmountRequested,
            TotalAnticipated        = r.TotalAnticipated,
            PercentAnticipated      = r.PercentAnticipated,
            RevenueDescriptionId    = r.RevenueDescriptionId,
            IsEarlyStart            = r.IsEarlyStart,
            EarlyStartReasonId      = r.EarlyStartReasonId,
            EarlyStartReasonOther   = r.EarlyStartReasonOther,
            Company                 = r.Company,
            IsEac                   = r.IsEac,
            Revision                = existing.Revision,
            StartDate               = r.StartDate,
            ExpirationDate          = r.ExpirationDate,
            ExportedAt              = existing.ExportedAt,
            NegatedAt               = existing.NegatedAt,
            CancelledAt             = existing.CancelledAt,
        };
}
