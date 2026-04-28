using ARA.Application.Common;
using ARA.Application.Delegation;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace ARA.Application.Tests.Delegation;

/// <summary>
/// Tests the <see cref="DelegationService"/> business rules for creating,
/// deactivating, and retrieving delegation records.
/// </summary>
public sealed class DelegationServiceTests
{
    private readonly Mock<IDelegationRepository> _delegationRepo = new();
    private readonly Mock<IUserRepository> _userRepo = new();
    private readonly DelegationService _sut;

    private const int DelegatorUserId = 10;
    private const int DelegateeUserId = 20;
    private const string DelegatorDisplayName = "Alice Delegator";
    private const string DelegateeDisplayName = "Bob Delegatee";

    public DelegationServiceTests()
    {
        _sut = new DelegationService(
            _delegationRepo.Object,
            _userRepo.Object,
            Mock.Of<ILogger<DelegationService>>());
    }

    // ── CreateDelegationAsync ────────────────────────────────────────────────

    [Fact]
    public async Task CreateDelegationAsync_SelfDelegation_ReturnsFailure()
    {
        CreateDelegationRequest request = new(DelegatorUserId, DateTime.UtcNow, DateTime.UtcNow.AddDays(7));

        Result<int> result = await _sut.CreateDelegationAsync(request, DelegatorUserId);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("cannot delegate to themselves");
    }

    [Fact]
    public async Task CreateDelegationAsync_DelegatorNotFound_ReturnsFailure()
    {
        CreateDelegationRequest request = new(DelegateeUserId, DateTime.UtcNow, DateTime.UtcNow.AddDays(7));
        SetupUserNotFound(DelegatorUserId);

        Result<int> result = await _sut.CreateDelegationAsync(request, DelegatorUserId);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("Delegator");
    }

    [Fact]
    public async Task CreateDelegationAsync_DelegateeNotFound_ReturnsFailure()
    {
        CreateDelegationRequest request = new(DelegateeUserId, DateTime.UtcNow, DateTime.UtcNow.AddDays(7));
        SetupUser(DelegatorUserId, DelegatorDisplayName, isInactive: false);
        SetupUserNotFound(DelegateeUserId);

        Result<int> result = await _sut.CreateDelegationAsync(request, DelegatorUserId);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not found or inactive");
    }

    [Fact]
    public async Task CreateDelegationAsync_DelegateeInactive_ReturnsFailure()
    {
        CreateDelegationRequest request = new(DelegateeUserId, DateTime.UtcNow, DateTime.UtcNow.AddDays(7));
        SetupUser(DelegatorUserId, DelegatorDisplayName, isInactive: false);
        SetupUser(DelegateeUserId, DelegateeDisplayName, isInactive: true);

        Result<int> result = await _sut.CreateDelegationAsync(request, DelegatorUserId);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not found or inactive");
    }

    [Fact]
    public async Task CreateDelegationAsync_ExistingActiveDelegation_ReturnsFailure()
    {
        CreateDelegationRequest request = new(DelegateeUserId, DateTime.UtcNow, DateTime.UtcNow.AddDays(7));
        SetupUser(DelegatorUserId, DelegatorDisplayName, isInactive: false);
        SetupUser(DelegateeUserId, DelegateeDisplayName, isInactive: false);
        SetupExistingActiveDelegation(DelegatorUserId);

        Result<int> result = await _sut.CreateDelegationAsync(request, DelegatorUserId);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("already has an active delegation");
    }

    [Fact]
    public async Task CreateDelegationAsync_EndDateBeforeStartDate_ReturnsFailure()
    {
        DateTime startDate = DateTime.UtcNow.AddDays(5);
        DateTime endDate = DateTime.UtcNow.AddDays(1);
        CreateDelegationRequest request = new(DelegateeUserId, startDate, endDate);
        SetupUser(DelegatorUserId, DelegatorDisplayName, isInactive: false);
        SetupUser(DelegateeUserId, DelegateeDisplayName, isInactive: false);
        SetupNoExistingDelegation(DelegatorUserId);

        Result<int> result = await _sut.CreateDelegationAsync(request, DelegatorUserId);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("End date must be after start date");
    }

    [Fact]
    public async Task CreateDelegationAsync_EndDateEqualsStartDate_ReturnsFailure()
    {
        DateTime sameDate = DateTime.UtcNow.AddDays(3);
        CreateDelegationRequest request = new(DelegateeUserId, sameDate, sameDate);
        SetupUser(DelegatorUserId, DelegatorDisplayName, isInactive: false);
        SetupUser(DelegateeUserId, DelegateeDisplayName, isInactive: false);
        SetupNoExistingDelegation(DelegatorUserId);

        Result<int> result = await _sut.CreateDelegationAsync(request, DelegatorUserId);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("End date must be after start date");
    }

    [Fact]
    public async Task CreateDelegationAsync_AllValid_ReturnsSuccessWithDelegationId()
    {
        int expectedDelegationId = 42;
        DateTime startDate = DateTime.UtcNow;
        DateTime endDate = DateTime.UtcNow.AddDays(7);
        CreateDelegationRequest request = new(DelegateeUserId, startDate, endDate);
        SetupUser(DelegatorUserId, DelegatorDisplayName, isInactive: false);
        SetupUser(DelegateeUserId, DelegateeDisplayName, isInactive: false);
        SetupNoExistingDelegation(DelegatorUserId);
        _delegationRepo.Setup(r => r.CreateAsync(It.IsAny<Domain.Entities.Delegation>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedDelegationId);

        Result<int> result = await _sut.CreateDelegationAsync(request, DelegatorUserId);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().Be(expectedDelegationId);
    }

    // ── DeactivateDelegationAsync ────────────────────────────────────────────

    [Fact]
    public async Task DeactivateDelegationAsync_ValidRequest_ReturnsSuccess()
    {
        int delegationId = 42;

        Result result = await _sut.DeactivateDelegationAsync(delegationId, DelegatorUserId);

        result.IsSuccess.Should().BeTrue();
        _delegationRepo.Verify(r => r.DeactivateAsync(delegationId, It.IsAny<CancellationToken>()), Times.Once);
    }

    // ── GetActiveDelegationsAsync ────────────────────────────────────────────

    [Fact]
    public async Task GetActiveDelegationsAsync_WithDelegations_ReturnsMappedDtos()
    {
        DateTime startDate = DateTime.UtcNow.AddDays(-1);
        DateTime endDate = DateTime.UtcNow.AddDays(5);
        List<Domain.Entities.Delegation> delegations =
        [
            new()
            {
                DelegationId = 1,
                DelegatorUserId = DelegatorUserId,
                DelegateeUserId = DelegateeUserId,
                StartDate = startDate,
                EndDate = endDate,
                IsActive = true,
            }
        ];
        _delegationRepo.Setup(r => r.GetActiveDelegationsAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(delegations.AsReadOnly());
        SetupUser(DelegatorUserId, DelegatorDisplayName, isInactive: false);
        SetupUser(DelegateeUserId, DelegateeDisplayName, isInactive: false);

        IReadOnlyList<DelegationDto> results = await _sut.GetActiveDelegationsAsync();

        results.Should().HaveCount(1);
        DelegationDto dto = results[0];
        dto.DelegationId.Should().Be(1);
        dto.DelegatorUserId.Should().Be(DelegatorUserId);
        dto.DelegatorDisplayName.Should().Be(DelegatorDisplayName);
        dto.DelegateeUserId.Should().Be(DelegateeUserId);
        dto.DelegateeDisplayName.Should().Be(DelegateeDisplayName);
        dto.StartDate.Should().Be(startDate);
        dto.EndDate.Should().Be(endDate);
        dto.IsActive.Should().BeTrue();
    }

    [Fact]
    public async Task GetActiveDelegationsAsync_NoDelegations_ReturnsEmptyList()
    {
        _delegationRepo.Setup(r => r.GetActiveDelegationsAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<Domain.Entities.Delegation>().AsReadOnly());

        IReadOnlyList<DelegationDto> results = await _sut.GetActiveDelegationsAsync();

        results.Should().BeEmpty();
    }

    // ── Test helpers ─────────────────────────────────────────────────────────

    private void SetupUser(int userId, string displayName, bool isInactive)
    {
        User user = new()
        {
            UserId = userId,
            DisplayName = displayName,
            IsInactive = isInactive,
            Email = $"user{userId}@test.com",
            ExternalUserId = $"ext-{userId}",
        };
        _userRepo.Setup(r => r.GetByIdAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);
    }

    private void SetupUserNotFound(int userId)
    {
        _userRepo.Setup(r => r.GetByIdAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);
    }

    private void SetupExistingActiveDelegation(int delegatorUserId)
    {
        Domain.Entities.Delegation existing = new()
        {
            DelegationId = 99,
            DelegatorUserId = delegatorUserId,
            DelegateeUserId = 999,
            StartDate = DateTime.UtcNow.AddDays(-1),
            EndDate = DateTime.UtcNow.AddDays(5),
            IsActive = true,
        };
        _delegationRepo.Setup(r => r.GetActiveDelegationForUserAsync(delegatorUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(existing);
    }

    private void SetupNoExistingDelegation(int delegatorUserId)
    {
        _delegationRepo.Setup(r => r.GetActiveDelegationForUserAsync(delegatorUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Domain.Entities.Delegation?)null);
    }
}
