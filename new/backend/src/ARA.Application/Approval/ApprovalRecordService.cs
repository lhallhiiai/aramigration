using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Approval;

/// <summary>Reads the approval history for an ARA via <see cref="IApprovalRecordRepository"/>.</summary>
public sealed class ApprovalRecordService : IApprovalRecordService
{
    private readonly IApprovalRecordRepository _repository;
    private readonly ILogger<ApprovalRecordService> _logger;

    /// <summary>Initializes a new instance of <see cref="ApprovalRecordService"/>.</summary>
    public ApprovalRecordService(IApprovalRecordRepository repository, ILogger<ApprovalRecordService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<ApprovalRecordDto>> GetByAraIdAsync(int araId, CancellationToken cancellationToken = default)
    {
        IReadOnlyList<ApprovalRecord> records = await _repository.GetByAraIdAsync(araId, cancellationToken);
        return records.Select(ToDto).ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<ApprovalRecordDto>> GetByAraIdAndRevisionAsync(int araId, int revision, CancellationToken cancellationToken = default)
    {
        IReadOnlyList<ApprovalRecord> records = await _repository.GetByAraIdAndRevisionAsync(araId, revision, cancellationToken);
        return records.Select(ToDto).ToList().AsReadOnly();
    }

    private static ApprovalRecordDto ToDto(ApprovalRecord r) =>
        new(r.ApprovalRecordId, r.AraId, r.ApproverId, r.JobTitleId, r.Action,
            r.SequenceOrder, r.Comment, r.RejectionReasonId, r.RejectionAreas,
            r.ActionTakenAt, r.AraRevision);
}
