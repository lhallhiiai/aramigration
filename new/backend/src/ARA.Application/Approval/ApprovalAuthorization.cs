using ARA.Domain.Enums;

namespace ARA.Application.Approval;

/// <summary>
/// Result of checking whether a user is authorized to act on the current approval step.
/// </summary>
public sealed record ApprovalAuthorization(
    bool IsAuthorized,
    int SequenceOrder,
    ApprovalActionType RequiredAction,
    int ActingAsUserId,
    int? ActingAsJobTitleId,
    bool IsDelegated);
