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
/// Tests the <see cref="ApprovalRoutingService"/> approval chain progression,
/// authorization, and delegation logic.
/// </summary>
public sealed class ApprovalRoutingServiceTests
{
    private readonly Mock<IAraRepository> _araRepo = new();
    private readonly Mock<IApprovalMatrixRepository> _matrixRepo = new();
    private readonly Mock<IApprovalRecordRepository> _approvalRepo = new();
    private readonly Mock<IUserRepository> _userRepo = new();
    private readonly Mock<IDelegationRepository> _delegationRepo = new();
    private readonly ApprovalRoutingService _sut;

    private const int TestAraId = 100;
    private const string TestDivision = "DIV01";

    public ApprovalRoutingServiceTests()
    {
        _sut = new ApprovalRoutingService(
            _araRepo.Object,
            _matrixRepo.Object,
            _approvalRepo.Object,
            _userRepo.Object,
            _delegationRepo.Object,
            Mock.Of<ILogger<ApprovalRoutingService>>());
    }

    // ── GetNextRequiredStepAsync ──────────────────────────────────────────────

    [Fact]
    public async Task GetNextRequiredStep_NoApprovalRecords_ReturnsFirstStep()
    {
        SetupAra(AraStatus.PendingApproval, amount: 100_000m);
        SetupMatrixForUnder500K();
        SetupNoApprovalRecords();

        Result<ApprovalStepResult?> result = await _sut.GetNextRequiredStepAsync(TestAraId);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().NotBeNull();
        result.Value!.SequenceOrder.Should().Be(4);
        result.Value.RoleName.Should().Be("Portfolio Leader");
    }

    [Fact]
    public async Task GetNextRequiredStep_SomeStepsCompleted_ReturnsNextIncomplete()
    {
        SetupAra(AraStatus.PendingApproval, amount: 100_000m);
        SetupMatrixForUnder500K();
        SetupApprovalRecords(completedSequences: [4, 5]);

        Result<ApprovalStepResult?> result = await _sut.GetNextRequiredStepAsync(TestAraId);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().NotBeNull();
        result.Value!.SequenceOrder.Should().Be(6);
    }

    [Fact]
    public async Task GetNextRequiredStep_AllComplete_ReturnsNull()
    {
        SetupAra(AraStatus.PendingApproval, amount: 100_000m);
        SetupMatrixForUnder500K();
        SetupApprovalRecords(completedSequences: [4, 5, 6, 7]);

        Result<ApprovalStepResult?> result = await _sut.GetNextRequiredStepAsync(TestAraId);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeNull();
    }

    [Fact]
    public async Task GetNextRequiredStep_AmountUnder500K_SkipsHighThresholdSteps()
    {
        SetupAra(AraStatus.PendingApproval, amount: 100_000m);
        SetupMatrixForUnder500K();
        SetupApprovalRecords(completedSequences: [4, 5, 6, 7]);

        Result<ApprovalStepResult?> result = await _sut.GetNextRequiredStepAsync(TestAraId);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().BeNull();
    }

    [Fact]
    public async Task GetNextRequiredStep_AmountAt500K_IncludesHighThresholdSteps()
    {
        SetupAra(AraStatus.PendingApproval, amount: 500_000m);
        SetupMatrixForOver500K();
        SetupApprovalRecords(completedSequences: [4, 5, 6, 7]);

        Result<ApprovalStepResult?> result = await _sut.GetNextRequiredStepAsync(TestAraId);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().NotBeNull();
        result.Value!.SequenceOrder.Should().Be(8);
        result.Value.RoleName.Should().Be("Finance Vice President");
    }

    [Fact]
    public async Task GetNextRequiredStep_AraNotPendingApproval_ReturnsFailure()
    {
        SetupAra(AraStatus.Draft, amount: 100_000m);

        Result<ApprovalStepResult?> result = await _sut.GetNextRequiredStepAsync(TestAraId);

        result.IsFailure.Should().BeTrue();
    }

    // ── AuthorizeApproverAsync ────────────────────────────────────────────────

    [Fact]
    public async Task AuthorizeApprover_MatchingJobTitleAndDivision_ReturnsAuthorized()
    {
        SetupAra(AraStatus.PendingApproval, amount: 100_000m);
        SetupMatrixForUnder500K();
        SetupNoApprovalRecords();

        int userId = 50;
        int portfolioLeaderJobTitleId = 4;
        SetupUser(userId, portfolioLeaderJobTitleId, TestDivision);
        SetupNoDelegations(userId);

        Result<ApprovalAuthorization> result = await _sut.AuthorizeApproverAsync(TestAraId, userId);

        result.IsSuccess.Should().BeTrue();
        result.Value!.IsAuthorized.Should().BeTrue();
        result.Value.SequenceOrder.Should().Be(4);
        result.Value.IsDelegated.Should().BeFalse();
    }

    [Fact]
    public async Task AuthorizeApprover_WrongJobTitle_ReturnsNotAuthorized()
    {
        SetupAra(AraStatus.PendingApproval, amount: 100_000m);
        SetupMatrixForUnder500K();
        SetupNoApprovalRecords();

        int userId = 50;
        int wrongJobTitleId = 99;
        SetupUser(userId, wrongJobTitleId, TestDivision);
        SetupNoDelegations(userId);

        Result<ApprovalAuthorization> result = await _sut.AuthorizeApproverAsync(TestAraId, userId);

        result.IsFailure.Should().BeTrue();
    }

    [Fact]
    public async Task AuthorizeApprover_CorrectJobTitleWrongDivision_ReturnsNotAuthorized()
    {
        SetupAra(AraStatus.PendingApproval, amount: 100_000m);
        SetupMatrixForUnder500K();
        SetupNoApprovalRecords();

        int userId = 50;
        int portfolioLeaderJobTitleId = 4;
        SetupUser(userId, portfolioLeaderJobTitleId, "OTHER_DIV");
        SetupNoDelegations(userId);

        Result<ApprovalAuthorization> result = await _sut.AuthorizeApproverAsync(TestAraId, userId);

        result.IsFailure.Should().BeTrue();
    }

    [Fact]
    public async Task AuthorizeApprover_DelegateOfMatchingUser_ReturnsAuthorizedViaDelegation()
    {
        SetupAra(AraStatus.PendingApproval, amount: 100_000m);
        SetupMatrixForUnder500K();
        SetupNoApprovalRecords();

        int delegateeId = 50;
        int delegatorId = 60;
        int portfolioLeaderJobTitleId = 4;

        SetupUser(delegateeId, jobTitleId: 99, approvalGroups: TestDivision);
        SetupUser(delegatorId, portfolioLeaderJobTitleId, TestDivision);
        SetupDelegation(delegatorId, delegateeId);

        Result<ApprovalAuthorization> result = await _sut.AuthorizeApproverAsync(TestAraId, delegateeId);

        result.IsSuccess.Should().BeTrue();
        result.Value!.IsAuthorized.Should().BeTrue();
        result.Value.IsDelegated.Should().BeTrue();
        result.Value.ActingAsUserId.Should().Be(delegatorId);
    }

    [Fact]
    public async Task AuthorizeApprover_SameUserAlreadyActedAtDifferentStep_Denied()
    {
        SetupAra(AraStatus.PendingApproval, amount: 100_000m);
        SetupMatrixForUnder500K();

        int userId = 50;
        int contractDirectorJobTitleId = 5;
        SetupUser(userId, contractDirectorJobTitleId, TestDivision);
        SetupNoDelegations(userId);

        List<ApprovalRecord> existingRecords =
        [
            new ApprovalRecord
            {
                AraId = TestAraId, ApproverId = userId, SequenceOrder = 4,
                Action = ApprovalActionType.Approve, AraRevision = 1
            }
        ];
        _approvalRepo.Setup(r => r.GetByAraIdAndRevisionAsync(TestAraId, 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existingRecords.AsReadOnly());

        SetupMatrixStepAt(5, contractDirectorJobTitleId);

        Result<ApprovalAuthorization> result = await _sut.AuthorizeApproverAsync(TestAraId, userId);

        result.IsFailure.Should().BeTrue();
    }

    [Fact]
    public async Task AuthorizeApprover_AllStepsComplete_ReturnsFailure()
    {
        SetupAra(AraStatus.PendingApproval, amount: 100_000m);
        SetupMatrixForUnder500K();
        SetupApprovalRecords(completedSequences: [4, 5, 6, 7]);

        int userId = 50;

        Result<ApprovalAuthorization> result = await _sut.AuthorizeApproverAsync(TestAraId, userId);

        result.IsFailure.Should().BeTrue();
    }

    // ── DivisionMatchesApprovalGroups ─────────────────────────────────────────

    [Fact]
    public void DivisionMatches_ExactMatch_ReturnsTrue()
    {
        bool result = ApprovalRoutingService.DivisionMatchesApprovalGroups("DIV01", "DIV01");
        result.Should().BeTrue();
    }

    [Fact]
    public void DivisionMatches_CaseInsensitive_ReturnsTrue()
    {
        bool result = ApprovalRoutingService.DivisionMatchesApprovalGroups("div01", "DIV01,DIV02");
        result.Should().BeTrue();
    }

    [Fact]
    public void DivisionMatches_NotInList_ReturnsFalse()
    {
        bool result = ApprovalRoutingService.DivisionMatchesApprovalGroups("DIV03", "DIV01,DIV02");
        result.Should().BeFalse();
    }

    [Fact]
    public void DivisionMatches_NullDivision_ReturnsFalse()
    {
        bool result = ApprovalRoutingService.DivisionMatchesApprovalGroups(null, "DIV01");
        result.Should().BeFalse();
    }

    [Fact]
    public void DivisionMatches_NullGroups_ReturnsFalse()
    {
        bool result = ApprovalRoutingService.DivisionMatchesApprovalGroups("DIV01", null);
        result.Should().BeFalse();
    }

    [Fact]
    public void DivisionMatches_MultipleGroups_MatchesCorrectOne()
    {
        bool result = ApprovalRoutingService.DivisionMatchesApprovalGroups("DIV02", "DIV01, DIV02, DIV03");
        result.Should().BeTrue();
    }

    // ── Test helpers ──────────────────────────────────────────────────────────

    private void SetupAra(AraStatus status, decimal amount)
    {
        Domain.Entities.Ara ara = new()
        {
            AraId = TestAraId,
            StatusId = (int)status,
            AmountTotal = amount,
            Division = TestDivision,
            Revision = 1,
            CategoryId = 1,
        };
        _araRepo.Setup(r => r.GetByIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);
    }

    private void SetupMatrixForUnder500K()
    {
        List<ApprovalMatrixEntry> entries =
        [
            new() { SequenceOrder = 4, RoleName = "Portfolio Leader", JobTitleId = 4, RequiredAction = ApprovalActionType.Approve, MinimumAmount = 0m },
            new() { SequenceOrder = 5, RoleName = "Contract Director", JobTitleId = 5, RequiredAction = ApprovalActionType.Review, MinimumAmount = 0m },
            new() { SequenceOrder = 6, RoleName = "Group Finance Manager", JobTitleId = 6, RequiredAction = ApprovalActionType.Review, MinimumAmount = 0m },
            new() { SequenceOrder = 7, RoleName = "Business Group President", JobTitleId = 7, RequiredAction = ApprovalActionType.Approve, MinimumAmount = 0m },
        ];
        _matrixRepo.Setup(r => r.GetRequiredEntriesForAmountAsync(It.IsAny<decimal>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(entries.AsReadOnly());
    }

    private void SetupMatrixForOver500K()
    {
        List<ApprovalMatrixEntry> entries =
        [
            new() { SequenceOrder = 4, RoleName = "Portfolio Leader", JobTitleId = 4, RequiredAction = ApprovalActionType.Approve, MinimumAmount = 0m },
            new() { SequenceOrder = 5, RoleName = "Contract Director", JobTitleId = 5, RequiredAction = ApprovalActionType.Review, MinimumAmount = 0m },
            new() { SequenceOrder = 6, RoleName = "Group Finance Manager", JobTitleId = 6, RequiredAction = ApprovalActionType.Review, MinimumAmount = 0m },
            new() { SequenceOrder = 7, RoleName = "Business Group President", JobTitleId = 7, RequiredAction = ApprovalActionType.Approve, MinimumAmount = 0m },
            new() { SequenceOrder = 8, RoleName = "Finance Vice President", JobTitleId = 8, RequiredAction = ApprovalActionType.Approve, MinimumAmount = 500_000m },
            new() { SequenceOrder = 9, RoleName = "SVP of Contracts & Procurement", JobTitleId = 9, RequiredAction = ApprovalActionType.Review, MinimumAmount = 500_000m },
            new() { SequenceOrder = 10, RoleName = "MTC COO", JobTitleId = 10, RequiredAction = ApprovalActionType.Approve, MinimumAmount = 500_000m },
        ];
        _matrixRepo.Setup(r => r.GetRequiredEntriesForAmountAsync(It.IsAny<decimal>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(entries.AsReadOnly());
    }

    private void SetupMatrixStepAt(int sequenceOrder, int jobTitleId)
    {
        List<ApprovalMatrixEntry> entries =
        [
            new() { SequenceOrder = sequenceOrder, RoleName = "Test Role", JobTitleId = jobTitleId, RequiredAction = ApprovalActionType.Review, MinimumAmount = 0m },
        ];
        _matrixRepo.Setup(r => r.GetRequiredEntriesForAmountAsync(It.IsAny<decimal>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(entries.AsReadOnly());
    }

    private void SetupNoApprovalRecords()
    {
        _approvalRepo.Setup(r => r.GetByAraIdAndRevisionAsync(TestAraId, 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<ApprovalRecord>().AsReadOnly());
    }

    private void SetupApprovalRecords(int[] completedSequences)
    {
        List<ApprovalRecord> records = completedSequences
            .Select(seq => new ApprovalRecord
            {
                AraId = TestAraId, ApproverId = seq * 10, SequenceOrder = seq,
                Action = ApprovalActionType.Approve, AraRevision = 1
            })
            .ToList();
        _approvalRepo.Setup(r => r.GetByAraIdAndRevisionAsync(TestAraId, 1, It.IsAny<CancellationToken>()))
            .ReturnsAsync(records.AsReadOnly());
    }

    private void SetupUser(int userId, int jobTitleId, string approvalGroups)
    {
        User user = new()
        {
            UserId = userId,
            JobTitleId = jobTitleId,
            ApprovalGroups = approvalGroups,
            IsInactive = false,
            DisplayName = $"User {userId}",
            Email = $"user{userId}@test.com",
            ExternalUserId = $"ext-{userId}",
        };
        _userRepo.Setup(r => r.GetByIdAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);
    }

    private void SetupNoDelegations(int userId)
    {
        _delegationRepo.Setup(r => r.GetActiveDelegationsForDelegateeAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<Domain.Entities.Delegation>().AsReadOnly());
    }

    private void SetupDelegation(int delegatorId, int delegateeId)
    {
        List<Domain.Entities.Delegation> delegations =
        [
            new()
            {
                DelegationId = 1,
                DelegatorUserId = delegatorId,
                DelegateeUserId = delegateeId,
                StartDate = DateTime.UtcNow.AddDays(-1),
                EndDate = DateTime.UtcNow.AddDays(1),
                IsActive = true,
            }
        ];
        _delegationRepo.Setup(r => r.GetActiveDelegationsForDelegateeAsync(delegateeId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(delegations.AsReadOnly());
    }
}
