using ARA.Domain.Enums;

namespace ARA.Application.Approval;

/// <summary>Approval log entry returned to the client for the Approval Cycle view.</summary>
public sealed record ApprovalRecordDto(
    int ApprovalRecordId,
    int AraId,
    int? ApproverId,
    int? JobTitleId,
    ApprovalActionType Action,
    int SequenceOrder,
    string? Comment,
    int? RejectionReasonId,
    string? RejectionAreas,
    DateTime ActionTakenAt,
    int AraRevision);
