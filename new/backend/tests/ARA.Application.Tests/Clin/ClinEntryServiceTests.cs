using ARA.Application.Clin;
using ARA.Application.Common;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace ARA.Application.Tests.Clin;

/// <summary>
/// Tests the <see cref="ClinEntryService"/> business rules for creating,
/// updating, deleting, and retrieving CLIN worksheet entries.
/// </summary>
public sealed class ClinEntryServiceTests
{
    private readonly Mock<IClinEntryRepository> _clinRepo = new();
    private readonly Mock<IAraRepository> _araRepo = new();
    private readonly ClinEntryService _sut;

    private const int TestAraId = 100;
    private const int TestClinEntryId = 50;
    private const string TestClinNumber = "CLIN-0001";
    private const string TestClinDescription = "Labor services";
    private const decimal TestCost = 10_000m;
    private const decimal TestFee = 1_500m;

    public ClinEntryServiceTests()
    {
        _sut = new ClinEntryService(
            _clinRepo.Object,
            _araRepo.Object,
            Mock.Of<ILogger<ClinEntryService>>());
    }

    // ── CreateAsync ──────────────────────────────────────────────────────────

    [Fact]
    public async Task CreateAsync_AraNotFound_ReturnsFailure()
    {
        SetupAraNotFound();
        CreateClinRequest request = new(TestClinNumber, TestClinDescription, TestCost, TestFee);

        Result<int> result = await _sut.CreateAsync(TestAraId, request);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain("not found");
    }

    [Fact]
    public async Task CreateAsync_DuplicateClinNumber_ReturnsFailure()
    {
        SetupAraExists();
        SetupExistingClinEntries(TestClinNumber);
        CreateClinRequest request = new(TestClinNumber, TestClinDescription, TestCost, TestFee);

        Result<int> result = await _sut.CreateAsync(TestAraId, request);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain(TestClinNumber);
    }

    [Fact]
    public async Task CreateAsync_DuplicateClinNumberCaseInsensitive_ReturnsFailure()
    {
        SetupAraExists();
        SetupExistingClinEntries(TestClinNumber.ToUpperInvariant());
        CreateClinRequest request = new(TestClinNumber.ToLowerInvariant(), TestClinDescription, TestCost, TestFee);

        Result<int> result = await _sut.CreateAsync(TestAraId, request);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().Contain(TestClinNumber.ToLowerInvariant());
    }

    [Fact]
    public async Task CreateAsync_ValidRequest_ReturnsSuccessWithId()
    {
        int expectedId = 77;
        SetupAraExists();
        SetupNoExistingClinEntries();
        _clinRepo.Setup(r => r.CreateAsync(It.IsAny<ClinEntry>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(expectedId);
        CreateClinRequest request = new(TestClinNumber, TestClinDescription, TestCost, TestFee);

        Result<int> result = await _sut.CreateAsync(TestAraId, request);

        result.IsSuccess.Should().BeTrue();
        result.Value.Should().Be(expectedId);
    }

    // ── GetByAraIdAsync ──────────────────────────────────────────────────────

    [Fact]
    public async Task GetByAraIdAsync_WithEntries_ReturnsMappedDtos()
    {
        List<ClinEntry> entries =
        [
            new()
            {
                ClinEntryId = TestClinEntryId,
                AraId = TestAraId,
                ClinNumber = TestClinNumber,
                ClinDescription = TestClinDescription,
                Cost = TestCost,
                Fee = TestFee,
            }
        ];
        _clinRepo.Setup(r => r.GetByAraIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(entries.AsReadOnly());

        IReadOnlyList<ClinEntryDto> results = await _sut.GetByAraIdAsync(TestAraId);

        results.Should().HaveCount(1);
        ClinEntryDto dto = results[0];
        dto.ClinEntryId.Should().Be(TestClinEntryId);
        dto.AraId.Should().Be(TestAraId);
        dto.ClinNumber.Should().Be(TestClinNumber);
        dto.ClinDescription.Should().Be(TestClinDescription);
        dto.Cost.Should().Be(TestCost);
        dto.Fee.Should().Be(TestFee);
        dto.Total.Should().Be(TestCost + TestFee);
    }

    [Fact]
    public async Task GetByAraIdAsync_NoEntries_ReturnsEmptyList()
    {
        _clinRepo.Setup(r => r.GetByAraIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<ClinEntry>().AsReadOnly());

        IReadOnlyList<ClinEntryDto> results = await _sut.GetByAraIdAsync(TestAraId);

        results.Should().BeEmpty();
    }

    // ── UpdateAsync ──────────────────────────────────────────────────────────

    [Fact]
    public async Task UpdateAsync_ValidRequest_ReturnsSuccessAndCallsRepository()
    {
        UpdateClinRequest request = new(TestClinEntryId, TestClinNumber, TestClinDescription, TestCost, TestFee);

        Result result = await _sut.UpdateAsync(request);

        result.IsSuccess.Should().BeTrue();
        _clinRepo.Verify(r => r.UpdateAsync(It.Is<ClinEntry>(e =>
            e.ClinEntryId == TestClinEntryId &&
            e.ClinNumber == TestClinNumber &&
            e.Cost == TestCost &&
            e.Fee == TestFee), It.IsAny<CancellationToken>()), Times.Once);
    }

    // ── DeleteAsync ──────────────────────────────────────────────────────────

    [Fact]
    public async Task DeleteAsync_ValidId_ReturnsSuccessAndCallsRepository()
    {
        Result result = await _sut.DeleteAsync(TestClinEntryId);

        result.IsSuccess.Should().BeTrue();
        _clinRepo.Verify(r => r.DeleteAsync(TestClinEntryId, It.IsAny<CancellationToken>()), Times.Once);
    }

    // ── Test helpers ─────────────────────────────────────────────────────────

    private void SetupAraExists()
    {
        Domain.Entities.Ara ara = new()
        {
            AraId = TestAraId,
            StatusId = 1,
            Revision = 1,
            CategoryId = 1,
        };
        _araRepo.Setup(r => r.GetByIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(ara);
    }

    private void SetupAraNotFound()
    {
        _araRepo.Setup(r => r.GetByIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Domain.Entities.Ara?)null);
    }

    private void SetupExistingClinEntries(string existingClinNumber)
    {
        List<ClinEntry> entries =
        [
            new()
            {
                ClinEntryId = 1,
                AraId = TestAraId,
                ClinNumber = existingClinNumber,
                Cost = 5_000m,
                Fee = 500m,
            }
        ];
        _clinRepo.Setup(r => r.GetByAraIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(entries.AsReadOnly());
    }

    [Fact]
    public async Task GetSummaryAsync_WithClinsThatExceedAraAmount_ReturnsSoftWarning()
    {
        decimal araAmount = 50_000m;
        _araRepo.Setup(r => r.GetByIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ARA.Domain.Entities.Ara { AraId = TestAraId, AmountTotal = araAmount });

        List<ClinEntry> entries =
        [
            new() { ClinEntryId = 1, AraId = TestAraId, ClinNumber = "CLIN-01", Cost = 30_000m, Fee = 5_000m },
            new() { ClinEntryId = 2, AraId = TestAraId, ClinNumber = "CLIN-02", Cost = 20_000m, Fee = 3_000m },
        ];
        _clinRepo.Setup(r => r.GetByAraIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(entries.AsReadOnly());

        ClinSummaryDto summary = await _sut.GetSummaryAsync(TestAraId, CancellationToken.None);

        summary.TotalCost.Should().Be(50_000m);
        summary.TotalFee.Should().Be(8_000m);
        summary.GrandTotal.Should().Be(58_000m);
        summary.AraAmount.Should().Be(araAmount);
        summary.ExceedsAraAmount.Should().BeTrue("combined CLIN funding exceeds ARA amount");
    }

    [Fact]
    public async Task GetSummaryAsync_WithClinsUnderAraAmount_NoWarning()
    {
        decimal araAmount = 100_000m;
        _araRepo.Setup(r => r.GetByIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ARA.Domain.Entities.Ara { AraId = TestAraId, AmountTotal = araAmount });

        List<ClinEntry> entries =
        [
            new() { ClinEntryId = 1, AraId = TestAraId, ClinNumber = "CLIN-01", Cost = 30_000m, Fee = 5_000m },
        ];
        _clinRepo.Setup(r => r.GetByAraIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(entries.AsReadOnly());

        ClinSummaryDto summary = await _sut.GetSummaryAsync(TestAraId, CancellationToken.None);

        summary.GrandTotal.Should().Be(35_000m);
        summary.ExceedsAraAmount.Should().BeFalse();
    }

    private void SetupNoExistingClinEntries()
    {
        _clinRepo.Setup(r => r.GetByAraIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<ClinEntry>().AsReadOnly());
    }
}
