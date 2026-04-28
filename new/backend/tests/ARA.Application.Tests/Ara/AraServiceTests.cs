using ARA.Application.Approval;
using ARA.Application.Ara;
using ARA.Application.Common;
using ARA.Application.Email;
using ARA.Domain.Entities;
using ARA.Domain.Enums;
using ARA.Domain.Repositories;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace ARA.Application.Tests.Ara;

/// <summary>
/// Tests for <see cref="AraService"/> covering all workflow transitions and guard clauses.
/// </summary>
public sealed class AraServiceTests
{
    private const int DefaultAraId = 100;
    private const int PmUserId = 10;
    private const int CaUserId = 20;
    private const int ControllerUserId = 30;
    private const int ApproverUserId = 40;
    private const int UnauthorizedUserId = 99;
    private const int DefaultRevision = 1;
    private const decimal DefaultAmount = 250_000m;
    private const string DefaultDivision = "DIV01";
    private const string DefaultContractNumber = "CONTRACT-001";

    private readonly Mock<IAraRepository> _araRepositoryMock;
    private readonly Mock<IApprovalRecordRepository> _approvalRecordRepositoryMock;
    private readonly Mock<IApprovalRoutingService> _routingServiceMock;
    private readonly Mock<IUserRepository> _userRepositoryMock;
    private readonly Mock<IEmailService> _emailServiceMock;
    private readonly Mock<ILogger<AraService>> _loggerMock;
    private readonly AraService _sut;

    public AraServiceTests()
    {
        _araRepositoryMock = new Mock<IAraRepository>();
        _approvalRecordRepositoryMock = new Mock<IApprovalRecordRepository>();
        _routingServiceMock = new Mock<IApprovalRoutingService>();
        _userRepositoryMock = new Mock<IUserRepository>();
        _emailServiceMock = new Mock<IEmailService>();
        _loggerMock = new Mock<ILogger<AraService>>();

        _sut = new AraService(
            _araRepositoryMock.Object,
            _approvalRecordRepositoryMock.Object,
            _routingServiceMock.Object,
            _userRepositoryMock.Object,
            _emailServiceMock.Object,
            _loggerMock.Object);
    }

    // ── Helper: build a test Ara entity ──────────────────────────────────────────

    private static Domain.Entities.Ara BuildAra(
        int araId = DefaultAraId,
        AraStatus status = AraStatus.Draft,
        int programManagerId = PmUserId,
        int contractAdministratorId = CaUserId,
        int controllerId = ControllerUserId,
        int revision = DefaultRevision,
        decimal amountTotal = DefaultAmount)
    {
        return new Domain.Entities.Ara
        {
            AraId = araId,
            StatusId = (int)status,
            ProgramManagerId = programManagerId,
            ContractAdministratorId = contractAdministratorId,
            ControllerId = controllerId,
            Revision = revision,
            AmountTotal = amountTotal,
            Division = DefaultDivision,
            ContractNumber = DefaultContractNumber,
            CategoryId = 1,
            CreatedByUserId = programManagerId,
        };
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CreateAsync
    // ═══════════════════════════════════════════════════════════════════════════

    [Fact]
    public async Task CreateAsync_ValidRequest_ReturnsDraftAraId()
    {
        // Arrange
        int expectedAraId = 42;
        CreateAraRequest request = new(
            CategoryId: 1,
            ProgramManagerId: PmUserId,
            ContractAdministratorId: CaUserId,
            ControllerId: ControllerUserId,
            OpsVpUserId: null,
            Division: DefaultDivision,
            ContractNumber: DefaultContractNumber,
            DeliveryOrderNumber: null,
            ContractType: "CPFF",
            OmsNumber: null,
            Title: "Test ARA",
            CustomerName: "Test Customer",
            AmountTotal: DefaultAmount,
            AmountRequested: null,
            TotalAnticipated: null,
            PercentAnticipated: null,
            RevenueDescriptionId: 1,
            IsEarlyStart: false,
            EarlyStartReasonId: null,
            EarlyStartReasonOther: null,
            Company: "HII",
            IsEac: null,
            StartDate: DateTime.UtcNow,
            ExpirationDate: DateTime.UtcNow.AddMonths(3));

        _araRepositoryMock
            .Setup(r => r.CreateAsync(It.Is<Domain.Entities.Ara>(a => a.StatusId == (int)AraStatus.Draft), It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedAraId);

        // Act
        Result<int> result = await _sut.CreateAsync(request, PmUserId);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.Value.Should().Be(expectedAraId);
        _araRepositoryMock.Verify(
            r => r.CreateAsync(It.Is<Domain.Entities.Ara>(a => a.StatusId == (int)AraStatus.Draft), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UpdateAsync
    // ═══════════════════════════════════════════════════════════════════════════

    [Fact]
    public async Task UpdateAsync_AraNotFound_ReturnsFailure()
    {
        // Arrange
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Domain.Entities.Ara?)null);

        UpdateAraRequest request = new(
            AraId: DefaultAraId,
            CategoryId: 1,
            ProgramManagerId: PmUserId,
            ContractAdministratorId: CaUserId,
            ControllerId: ControllerUserId,
            OpsVpUserId: null,
            Reference: null,
            JamisId: null,
            Division: DefaultDivision,
            ContractNumber: DefaultContractNumber,
            DeliveryOrderNumber: null,
            ContractType: "CPFF",
            OmsNumber: null,
            Title: "Updated Title",
            CustomerName: "Customer",
            AmountTotal: DefaultAmount,
            AmountRequested: null,
            TotalAnticipated: null,
            PercentAnticipated: null,
            RevenueDescriptionId: 1,
            IsEarlyStart: false,
            EarlyStartReasonId: null,
            EarlyStartReasonOther: null,
            Company: "HII",
            IsEac: null,
            StartDate: DateTime.UtcNow,
            ExpirationDate: DateTime.UtcNow.AddMonths(3));

        // Act
        Result result = await _sut.UpdateAsync(request);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not found");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SubmitByPmAsync
    // ═══════════════════════════════════════════════════════════════════════════

    [Fact]
    public async Task SubmitByPmAsync_DraftAndCorrectPm_TransitionsToPendingCa()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Draft);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.SubmitByPmAsync(DefaultAraId, PmUserId);

        // Assert
        result.IsSuccess.Should().BeTrue();
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.PendingContractAdministrator, DefaultRevision, null, null, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task SubmitByPmAsync_AraNotFound_ReturnsFailure()
    {
        // Arrange
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Domain.Entities.Ara?)null);

        // Act
        Result result = await _sut.SubmitByPmAsync(DefaultAraId, PmUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not found");
    }

    [Fact]
    public async Task SubmitByPmAsync_NotInDraftStatus_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingContractAdministrator);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.SubmitByPmAsync(DefaultAraId, PmUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("Draft");
    }

    [Fact]
    public async Task SubmitByPmAsync_WrongUser_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Draft);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.SubmitByPmAsync(DefaultAraId, UnauthorizedUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("Program Manager");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SubmitByCaAsync
    // ═══════════════════════════════════════════════════════════════════════════

    [Fact]
    public async Task SubmitByCaAsync_PendingCaAndCorrectCa_TransitionsToPendingController()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingContractAdministrator);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.SubmitByCaAsync(DefaultAraId, CaUserId);

        // Assert
        result.IsSuccess.Should().BeTrue();
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.PendingController, DefaultRevision, null, null, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task SubmitByCaAsync_WrongStatus_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Draft);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.SubmitByCaAsync(DefaultAraId, CaUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("PendingContractAdministrator");
    }

    [Fact]
    public async Task SubmitByCaAsync_WrongUser_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingContractAdministrator);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.SubmitByCaAsync(DefaultAraId, UnauthorizedUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("Contract Administrator");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SubmitByControllerAsync
    // ═══════════════════════════════════════════════════════════════════════════

    [Fact]
    public async Task SubmitByControllerAsync_PendingControllerAndCorrectUser_TransitionsToPendingApproval()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingController);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.SubmitByControllerAsync(DefaultAraId, ControllerUserId);

        // Assert
        result.IsSuccess.Should().BeTrue();
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.PendingApproval, DefaultRevision, null, null, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task SubmitByControllerAsync_WrongStatus_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingContractAdministrator);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.SubmitByControllerAsync(DefaultAraId, ControllerUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("PendingController");
    }

    [Fact]
    public async Task SubmitByControllerAsync_WrongUser_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingController);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.SubmitByControllerAsync(DefaultAraId, UnauthorizedUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("Controller");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ApproveAsync
    // ═══════════════════════════════════════════════════════════════════════════

    [Fact]
    public async Task ApproveAsync_WithNextStep_StaysPendingApprovalAndRecordsAction()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingApproval);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        ApprovalAuthorization authorization = new(
            IsAuthorized: true,
            SequenceOrder: 4,
            RequiredAction: ApprovalActionType.Approve,
            ActingAsUserId: ApproverUserId,
            ActingAsJobTitleId: 1,
            IsDelegated: false);

        _routingServiceMock
            .Setup(r => r.AuthorizeApproverAsync(DefaultAraId, ApproverUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ApprovalAuthorization>.Success(authorization));

        ApprovalStepResult nextStep = new(
            SequenceOrder: 5,
            RoleName: "Contract Director",
            JobTitleId: 2,
            RequiredAction: ApprovalActionType.Review,
            MinimumAmount: 0m,
            IsCompleted: false);

        _routingServiceMock
            .Setup(r => r.GetNextRequiredStepAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ApprovalStepResult?>.Success(nextStep));

        // Act
        Result result = await _sut.ApproveAsync(DefaultAraId, ApproverUserId, "Looks good");

        // Assert
        result.IsSuccess.Should().BeTrue();
        _approvalRecordRepositoryMock.Verify(
            r => r.CreateAsync(It.Is<ApprovalRecord>(rec =>
                rec.AraId == DefaultAraId &&
                rec.ApproverId == ApproverUserId &&
                rec.Action == ApprovalActionType.Approve &&
                rec.SequenceOrder == 4),
                It.IsAny<CancellationToken>()),
            Times.Once);
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.Approved, It.IsAny<int>(), It.IsAny<DateTime?>(), It.IsAny<DateTime?>(), It.IsAny<CancellationToken>()),
            Times.Never);
    }

    [Fact]
    public async Task ApproveAsync_FinalStep_TransitionsToApproved()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingApproval);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        ApprovalAuthorization authorization = new(
            IsAuthorized: true,
            SequenceOrder: 7,
            RequiredAction: ApprovalActionType.Approve,
            ActingAsUserId: ApproverUserId,
            ActingAsJobTitleId: 3,
            IsDelegated: false);

        _routingServiceMock
            .Setup(r => r.AuthorizeApproverAsync(DefaultAraId, ApproverUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ApprovalAuthorization>.Success(authorization));

        _routingServiceMock
            .Setup(r => r.GetNextRequiredStepAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ApprovalStepResult?>.Success(null));

        // Act
        Result result = await _sut.ApproveAsync(DefaultAraId, ApproverUserId, "Final approval");

        // Assert
        result.IsSuccess.Should().BeTrue();
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.Approved, DefaultRevision, null, null, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task ApproveAsync_NotInPendingApproval_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingController);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.ApproveAsync(DefaultAraId, ApproverUserId, "comment");

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("PendingApproval");
    }

    [Fact]
    public async Task ApproveAsync_AuthorizationFails_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingApproval);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        _routingServiceMock
            .Setup(r => r.AuthorizeApproverAsync(DefaultAraId, UnauthorizedUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ApprovalAuthorization>.Failure("User is not authorized for the current approval step."));

        // Act
        Result result = await _sut.ApproveAsync(DefaultAraId, UnauthorizedUserId, "comment");

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not authorized");
    }

    [Fact]
    public async Task ApproveAsync_AraNotFound_ReturnsFailure()
    {
        // Arrange
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Domain.Entities.Ara?)null);

        // Act
        Result result = await _sut.ApproveAsync(DefaultAraId, ApproverUserId, "comment");

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not found");
    }

    [Fact]
    public async Task ApproveAsync_DelegatedApprover_RecordsDelegatorUserId()
    {
        // Arrange
        int delegateeUserId = 50;
        int delegatorUserId = ApproverUserId;
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingApproval);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        ApprovalAuthorization authorization = new(
            IsAuthorized: true,
            SequenceOrder: 4,
            RequiredAction: ApprovalActionType.Approve,
            ActingAsUserId: delegatorUserId,
            ActingAsJobTitleId: 1,
            IsDelegated: true);

        _routingServiceMock
            .Setup(r => r.AuthorizeApproverAsync(DefaultAraId, delegateeUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ApprovalAuthorization>.Success(authorization));

        ApprovalStepResult nextStep = new(5, "Contract Director", 2, ApprovalActionType.Review, 0m, false);
        _routingServiceMock
            .Setup(r => r.GetNextRequiredStepAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ApprovalStepResult?>.Success(nextStep));

        // Act
        Result result = await _sut.ApproveAsync(DefaultAraId, delegateeUserId, "Approved on behalf");

        // Assert
        result.IsSuccess.Should().BeTrue();
        _approvalRecordRepositoryMock.Verify(
            r => r.CreateAsync(It.Is<ApprovalRecord>(rec =>
                rec.DelegatorUserId == delegatorUserId &&
                rec.ApproverId == delegateeUserId),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RejectAsync
    // ═══════════════════════════════════════════════════════════════════════════

    [Fact]
    public async Task RejectAsync_ByCaFromPendingCa_ReturnsToDraftAndIncrementsRevision()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingContractAdministrator, revision: 1);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        RejectRequest request = new(
            Comment: "Insufficient documentation",
            RejectionReasonId: 1,
            RejectionAreas: "Program Mgr");

        // Act
        Result result = await _sut.RejectAsync(DefaultAraId, CaUserId, request);

        // Assert
        result.IsSuccess.Should().BeTrue();
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.Draft, 2, null, null, It.IsAny<CancellationToken>()),
            Times.Once);
        _approvalRecordRepositoryMock.Verify(
            r => r.CreateAsync(It.Is<ApprovalRecord>(rec =>
                rec.Action == ApprovalActionType.Reject &&
                rec.SequenceOrder == 2 &&
                rec.AraRevision == 1),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task RejectAsync_ByControllerFromPendingController_ReturnsToDraftAndIncrementsRevision()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingController, revision: 2);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        RejectRequest request = new(
            Comment: "CLIN data mismatch",
            RejectionReasonId: 2,
            RejectionAreas: "Controller");

        // Act
        Result result = await _sut.RejectAsync(DefaultAraId, ControllerUserId, request);

        // Assert
        result.IsSuccess.Should().BeTrue();
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.Draft, 3, null, null, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task RejectAsync_ByApproverFromPendingApproval_ReturnsToDraftAndIncrementsRevision()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingApproval, revision: 1);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        ApprovalAuthorization authorization = new(
            IsAuthorized: true,
            SequenceOrder: 5,
            RequiredAction: ApprovalActionType.Approve,
            ActingAsUserId: ApproverUserId,
            ActingAsJobTitleId: 2,
            IsDelegated: false);

        _routingServiceMock
            .Setup(r => r.AuthorizeApproverAsync(DefaultAraId, ApproverUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ApprovalAuthorization>.Success(authorization));

        RejectRequest request = new(
            Comment: "Amount does not match supporting docs",
            RejectionReasonId: 4,
            RejectionAreas: "Program Mgr;Controller");

        // Act
        Result result = await _sut.RejectAsync(DefaultAraId, ApproverUserId, request);

        // Assert
        result.IsSuccess.Should().BeTrue();
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.Draft, 2, null, null, It.IsAny<CancellationToken>()),
            Times.Once);
        _approvalRecordRepositoryMock.Verify(
            r => r.CreateAsync(It.Is<ApprovalRecord>(rec =>
                rec.Action == ApprovalActionType.Reject &&
                rec.SequenceOrder == 5),
                It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task RejectAsync_AraNotFound_ReturnsFailure()
    {
        // Arrange
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Domain.Entities.Ara?)null);

        RejectRequest request = new("reason", 1, null);

        // Act
        Result result = await _sut.RejectAsync(DefaultAraId, CaUserId, request);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not found");
    }

    [Fact]
    public async Task RejectAsync_NotInRejectableState_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Draft);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        RejectRequest request = new("reason", 1, null);

        // Act
        Result result = await _sut.RejectAsync(DefaultAraId, CaUserId, request);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not in a rejectable state");
    }

    [Fact]
    public async Task RejectAsync_ApproverAuthorizationFails_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingApproval);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        _routingServiceMock
            .Setup(r => r.AuthorizeApproverAsync(DefaultAraId, UnauthorizedUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ApprovalAuthorization>.Failure("Not authorized for this step."));

        RejectRequest request = new("reason", 1, null);

        // Act
        Result result = await _sut.RejectAsync(DefaultAraId, UnauthorizedUserId, request);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("Cannot reject");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CancelAsync
    // ═══════════════════════════════════════════════════════════════════════════

    [Fact]
    public async Task CancelAsync_PmCancelsDraft_TransitionsToCancelled()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Draft);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.CancelAsync(DefaultAraId, PmUserId);

        // Assert
        result.IsSuccess.Should().BeTrue();
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.Cancelled, DefaultRevision, It.IsAny<DateTime?>(), null, It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task CancelAsync_PmCancelsPendingCa_TransitionsToCancelled()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.PendingContractAdministrator);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.CancelAsync(DefaultAraId, PmUserId);

        // Assert
        result.IsSuccess.Should().BeTrue();
    }

    [Fact]
    public async Task CancelAsync_NonPmUser_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Draft);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.CancelAsync(DefaultAraId, UnauthorizedUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("Program Manager");
    }

    [Fact]
    public async Task CancelAsync_TerminalStatusApproved_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Approved);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.CancelAsync(DefaultAraId, PmUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("cannot be cancelled");
    }

    [Fact]
    public async Task CancelAsync_TerminalStatusExpired_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Expired);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.CancelAsync(DefaultAraId, PmUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("cannot be cancelled");
    }

    [Fact]
    public async Task CancelAsync_AraNotFound_ReturnsFailure()
    {
        // Arrange
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Domain.Entities.Ara?)null);

        // Act
        Result result = await _sut.CancelAsync(DefaultAraId, PmUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not found");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // NegateAsync
    // ═══════════════════════════════════════════════════════════════════════════

    [Fact]
    public async Task NegateAsync_CaNegatesApprovedAra_TransitionsToNegated()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Approved);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.NegateAsync(DefaultAraId, CaUserId);

        // Assert
        result.IsSuccess.Should().BeTrue();
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.Negated, DefaultRevision, null, It.IsAny<DateTime?>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task NegateAsync_CaNegatesExportedAra_TransitionsToNegated()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Exported);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.NegateAsync(DefaultAraId, CaUserId);

        // Assert
        result.IsSuccess.Should().BeTrue();
        _araRepositoryMock.Verify(
            r => r.UpdateStatusAsync(DefaultAraId, AraStatus.Negated, DefaultRevision, null, It.IsAny<DateTime?>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task NegateAsync_NonCaUser_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Approved);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.NegateAsync(DefaultAraId, UnauthorizedUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("Contract Administrator");
    }

    [Fact]
    public async Task NegateAsync_WrongStatus_ReturnsFailure()
    {
        // Arrange
        Domain.Entities.Ara ara = BuildAra(status: AraStatus.Draft);
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);

        // Act
        Result result = await _sut.NegateAsync(DefaultAraId, CaUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("Approved or Exported");
    }

    [Fact]
    public async Task NegateAsync_AraNotFound_ReturnsFailure()
    {
        // Arrange
        _araRepositoryMock
            .Setup(r => r.GetByIdAsync(DefaultAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Domain.Entities.Ara?)null);

        // Act
        Result result = await _sut.NegateAsync(DefaultAraId, CaUserId);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not found");
    }
}
