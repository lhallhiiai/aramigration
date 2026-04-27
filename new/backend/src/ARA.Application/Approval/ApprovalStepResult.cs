using ARA.Domain.Enums;

namespace ARA.Application.Approval;

/// <summary>
/// Represents a single step in the approval chain for an ARA, including
/// whether the step has been completed in the current revision.
/// </summary>
public sealed record ApprovalStepResult(
    int SequenceOrder,
    string RoleName,
    int JobTitleId,
    ApprovalActionType RequiredAction,
    decimal MinimumAmount,
    bool IsCompleted);
