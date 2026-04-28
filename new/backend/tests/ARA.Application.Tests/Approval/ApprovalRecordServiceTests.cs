using ARA.Application.Approval;
using ARA.Application.Common;
using ARA.Domain.Entities;
using ARA.Domain.Enums;
using ARA.Domain.Repositories;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace ARA.Application.Tests.Approval;

/// <summary>
/// Tests for <see cref="ApprovalRecordService"/> covering approval record retrieval
/// by ARA ID and by ARA ID with revision filtering.
/// </summary>
public sealed class ApprovalRecordServiceTests
{
    private readonly Mock<IApprovalRecordRepository> _approvalRecordRepo = new();
    private readonly ApprovalRecordService _sut;

    private static readonly DateTime ActionTime = new(2026, 4, 20, 14, 0, 0, DateTimeKind.Utc);

    public ApprovalRecordServiceTests()
    {
        _sut = new ApprovalRecordService(
            _approvalRecordRepo.Object,
            Mock.Of<ILogger<ApprovalRecordService>>());
    }

    [Fact]
    public async Task GetByAraIdAsync_WithRecords_ReturnsMappedDtos()
    {
        List<ApprovalRecord> records =
        [
            new()
            {
                ApprovalRecordId = 1, AraId = 100, ApproverId = 10, JobTitleId = 4,
                Action = ApprovalActionType.Approve, SequenceOrder = 4, Comment = "Looks good",
                RejectionReasonId = null, RejectionAreas = null, ActionTakenAt = ActionTime, AraRevision = 1,
            },
            new()
            {
                ApprovalRecordId = 2, AraId = 100, ApproverId = 20, JobTitleId = 5,
                Action = ApprovalActionType.Review, SequenceOrder = 5, Comment = null,
                RejectionReasonId = null, RejectionAreas = null, ActionTakenAt = ActionTime, AraRevision = 1,
            },
        ];
        _approvalRecordRepo.Setup(r => r.GetByAraIdAsync(100, It.IsAny<CancellationToken>()))
            .ReturnsAsync(records.AsReadOnly());

        IReadOnlyList<ApprovalRecordDto> result = await _sut.GetByAraIdAsync(100, CancellationToken.None);

        result.Should().HaveCount(2);
        result[0].ApprovalRecordId.Should().Be(1);
        result[0].AraId.Should().Be(100);
        result[0].ApproverId.Should().Be(10);
        result[0].JobTitleId.Should().Be(4);
        result[0].Action.Should().Be(ApprovalActionType.Approve);
        result[0].SequenceOrder.Should().Be(4);
        result[0].Comment.Should().Be("Looks good");
        result[0].ActionTakenAt.Should().Be(ActionTime);
        result[0].AraRevision.Should().Be(1);
        result[1].ApprovalRecordId.Should().Be(2);
        result[1].Action.Should().Be(ApprovalActionType.Review);
    }

    [Fact]
    public async Task GetByAraIdAndRevisionAsync_WithMatchingRevision_ReturnsFilteredDtos()
    {
        List<ApprovalRecord> records =
        [
            new()
            {
                ApprovalRecordId = 3, AraId = 100, ApproverId = 30, JobTitleId = 6,
                Action = ApprovalActionType.Reject, SequenceOrder = 6,
                Comment = "Insufficient documentation", RejectionReasonId = 1,
                RejectionAreas = "Documents", ActionTakenAt = ActionTime, AraRevision = 2,
            },
        ];
        _approvalRecordRepo.Setup(r => r.GetByAraIdAndRevisionAsync(100, 2, It.IsAny<CancellationToken>()))
            .ReturnsAsync(records.AsReadOnly());

        IReadOnlyList<ApprovalRecordDto> result = await _sut.GetByAraIdAndRevisionAsync(100, 2, CancellationToken.None);

        result.Should().HaveCount(1);
        result[0].AraRevision.Should().Be(2);
        result[0].Action.Should().Be(ApprovalActionType.Reject);
        result[0].RejectionReasonId.Should().Be(1);
        result[0].RejectionAreas.Should().Be("Documents");
    }

    [Fact]
    public async Task GetByAraIdAndRevisionAsync_WithNoRecords_ReturnsEmptyList()
    {
        _approvalRecordRepo.Setup(r => r.GetByAraIdAndRevisionAsync(100, 5, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<ApprovalRecord>().AsReadOnly());

        IReadOnlyList<ApprovalRecordDto> result = await _sut.GetByAraIdAndRevisionAsync(100, 5, CancellationToken.None);

        result.Should().BeEmpty();
    }
}
