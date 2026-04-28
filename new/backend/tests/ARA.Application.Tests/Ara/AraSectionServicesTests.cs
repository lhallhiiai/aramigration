using ARA.Application.Ara.Sections;
using ARA.Application.Common;
using ARA.Domain.Entities;
using ARA.Domain.Repositories;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace ARA.Application.Tests.Ara;

/// <summary>
/// Unit tests for <see cref="AraPmSectionService"/> and
/// <see cref="AraControllerSectionService"/>. Both services are thin DTO
/// mapping wrappers over a single repository (Get + Upsert).
/// </summary>
public sealed class AraSectionServicesTests
{
    private const int TestAraId = 100;
    private const int TestControllerId = 5;

    // ── PM section ────────────────────────────────────────────────────────────

    [Fact]
    public async Task PmSection_GetByAraIdAsync_WithExistingSection_ReturnsDto()
    {
        AraPmSection entity = new()
        {
            AraPmSectionId = 9,
            AraId = TestAraId,
            FundsInAdvance = "Justify risk",
            CurrentStatus = "Status",
        };
        Mock<IAraPmSectionRepository> repo = new();
        repo.Setup(r => r.GetByAraIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(entity);
        AraPmSectionService sut = new(repo.Object, Mock.Of<ILogger<AraPmSectionService>>());

        AraPmSectionDto? result = await sut.GetByAraIdAsync(TestAraId);

        result.Should().NotBeNull();
        result!.AraId.Should().Be(TestAraId);
        result.FundsInAdvance.Should().Be("Justify risk");
        result.CurrentStatus.Should().Be("Status");
    }

    [Fact]
    public async Task PmSection_GetByAraIdAsync_WithMissingSection_ReturnsNull()
    {
        Mock<IAraPmSectionRepository> repo = new();
        repo.Setup(r => r.GetByAraIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((AraPmSection?)null);
        AraPmSectionService sut = new(repo.Object, Mock.Of<ILogger<AraPmSectionService>>());

        AraPmSectionDto? result = await sut.GetByAraIdAsync(TestAraId);

        result.Should().BeNull();
    }

    [Fact]
    public async Task PmSection_SaveAsync_BuildsEntityFromRequestAndUpserts()
    {
        Mock<IAraPmSectionRepository> repo = new();
        repo.Setup(r => r.UpsertAsync(It.IsAny<AraPmSection>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        AraPmSectionService sut = new(repo.Object, Mock.Of<ILogger<AraPmSectionService>>());

        SaveAraPmSectionRequest request = new(
            FundsInAdvance: "f1",
            ContractDefinization: "f2",
            PertinentInformation: "f3",
            WorkStarted: "f4",
            Consequence: "f5",
            CurrentStatus: "f6",
            ChangeInScope: null,
            ActionToClear: null,
            EarlyStartNecessary: null,
            OtherNecessary: null);

        Result result = await sut.SaveAsync(TestAraId, request);

        result.IsSuccess.Should().BeTrue();
        repo.Verify(r => r.UpsertAsync(
            It.Is<AraPmSection>(s =>
                s.AraId == TestAraId
                && s.FundsInAdvance == "f1"
                && s.CurrentStatus == "f6"),
            It.IsAny<CancellationToken>()),
            Times.Once);
    }

    // ── Controller section ────────────────────────────────────────────────────

    [Fact]
    public async Task ControllerSection_GetByAraIdAsync_WithExistingSection_ReturnsDto()
    {
        AraControllerSection entity = new()
        {
            AraControllerSectionId = 11,
            AraId = TestAraId,
            ControllerId = TestControllerId,
            InterestImpact = 0d,
            BurnRate = 1234.56d,
            IncurredCost = 100d,
            IncurredFee = 10d,
            Company = "ACME",
            TotalCost = 1000d,
            TotalFee = 100d,
        };
        Mock<IAraControllerSectionRepository> repo = new();
        repo.Setup(r => r.GetByAraIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(entity);
        AraControllerSectionService sut = new(repo.Object, Mock.Of<ILogger<AraControllerSectionService>>());

        AraControllerSectionDto? result = await sut.GetByAraIdAsync(TestAraId);

        result.Should().NotBeNull();
        result!.ControllerId.Should().Be(TestControllerId);
        result.BurnRate.Should().Be(1234.56d);
        result.TotalCost.Should().Be(1000d);
    }

    [Fact]
    public async Task ControllerSection_GetByAraIdAsync_WithMissingSection_ReturnsNull()
    {
        Mock<IAraControllerSectionRepository> repo = new();
        repo.Setup(r => r.GetByAraIdAsync(TestAraId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((AraControllerSection?)null);
        AraControllerSectionService sut = new(repo.Object, Mock.Of<ILogger<AraControllerSectionService>>());

        AraControllerSectionDto? result = await sut.GetByAraIdAsync(TestAraId);

        result.Should().BeNull();
    }

    [Fact]
    public async Task ControllerSection_SaveAsync_BuildsEntityFromRequestAndUpserts()
    {
        Mock<IAraControllerSectionRepository> repo = new();
        repo.Setup(r => r.UpsertAsync(It.IsAny<AraControllerSection>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);
        AraControllerSectionService sut = new(repo.Object, Mock.Of<ILogger<AraControllerSectionService>>());

        SaveAraControllerSectionRequest request = new(
            InterestImpact: 0d,
            BurnRate: 5000d,
            IncurredCost: 100d,
            IncurredFee: 10d,
            Company: "Test Company");

        Result result = await sut.SaveAsync(TestAraId, TestControllerId, request);

        result.IsSuccess.Should().BeTrue();
        repo.Verify(r => r.UpsertAsync(
            It.Is<AraControllerSection>(s =>
                s.AraId == TestAraId
                && s.ControllerId == TestControllerId
                && s.BurnRate == 5000d
                && s.Company == "Test Company"),
            It.IsAny<CancellationToken>()),
            Times.Once);
    }
}
