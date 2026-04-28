using ARA.Application.JobTitle;
using ARA.Application.RejectionReason;
using ARA.Domain.Repositories;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace ARA.Application.Tests.Lookups;

/// <summary>
/// Unit tests for the small read-only lookup services
/// (<see cref="JobTitleService"/>, <see cref="RejectionReasonService"/>).
/// Both are thin DTO projections over a single repository call.
/// </summary>
public sealed class LookupServiceTests
{
    private readonly Mock<IJobTitleRepository> _jobTitleRepo = new();
    private readonly Mock<IRejectionReasonRepository> _reasonRepo = new();

    [Fact]
    public async Task JobTitleService_GetAllActiveAsync_ProjectsEntitiesToDtos()
    {
        IReadOnlyList<Domain.Entities.JobTitle> entities = new List<Domain.Entities.JobTitle>
        {
            new() { JobTitleId = 1, Title = "PM",         Description = null,           AppOrder = null },
            new() { JobTitleId = 2, Title = "CA",         Description = "Contracts",    AppOrder = null },
            new() { JobTitleId = 8, Title = "Finance VP", Description = "Finance lead", AppOrder = 8 },
        };
        _jobTitleRepo
            .Setup(r => r.GetAllActiveAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(entities);
        JobTitleService sut = new(_jobTitleRepo.Object, Mock.Of<ILogger<JobTitleService>>());

        IReadOnlyList<JobTitleDto> result = await sut.GetAllActiveAsync();

        result.Should().HaveCount(3);
        result[0].Should().BeEquivalentTo(new JobTitleDto(1, "PM", null, null));
        result[1].Should().BeEquivalentTo(new JobTitleDto(2, "CA", "Contracts", null));
        result[2].Should().BeEquivalentTo(new JobTitleDto(8, "Finance VP", "Finance lead", 8));
    }

    [Fact]
    public async Task JobTitleService_GetAllActiveAsync_WithEmptyRepo_ReturnsEmpty()
    {
        _jobTitleRepo
            .Setup(r => r.GetAllActiveAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(Array.Empty<Domain.Entities.JobTitle>());
        JobTitleService sut = new(_jobTitleRepo.Object, Mock.Of<ILogger<JobTitleService>>());

        IReadOnlyList<JobTitleDto> result = await sut.GetAllActiveAsync();

        result.Should().BeEmpty();
    }

    [Fact]
    public async Task RejectionReasonService_GetAllActiveAsync_ProjectsEntitiesToDtos()
    {
        IReadOnlyList<Domain.Entities.RejectionReason> entities = new List<Domain.Entities.RejectionReason>
        {
            new() { RejectionReasonId = 1, Description = "Supporting Documentation is Insufficient", DisplayOrder = 1 },
            new() { RejectionReasonId = 2, Description = "Incorrect CLIN Number Used",                 DisplayOrder = 2 },
            new() { RejectionReasonId = 6, Description = "Other",                                      DisplayOrder = 6 },
        };
        _reasonRepo
            .Setup(r => r.GetAllActiveAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(entities);
        RejectionReasonService sut = new(_reasonRepo.Object, Mock.Of<ILogger<RejectionReasonService>>());

        IReadOnlyList<RejectionReasonDto> result = await sut.GetAllActiveAsync();

        result.Should().HaveCount(3);
        result[2].Should().BeEquivalentTo(new RejectionReasonDto(6, "Other", 6));
    }

    [Fact]
    public async Task RejectionReasonService_GetAllActiveAsync_WithEmptyRepo_ReturnsEmpty()
    {
        _reasonRepo
            .Setup(r => r.GetAllActiveAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(Array.Empty<Domain.Entities.RejectionReason>());
        RejectionReasonService sut = new(_reasonRepo.Object, Mock.Of<ILogger<RejectionReasonService>>());

        IReadOnlyList<RejectionReasonDto> result = await sut.GetAllActiveAsync();

        result.Should().BeEmpty();
    }
}
