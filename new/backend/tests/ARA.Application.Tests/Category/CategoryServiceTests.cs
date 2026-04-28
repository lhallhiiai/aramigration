using ARA.Application.Category;
using ARA.Application.Common;
using ARA.Domain.Repositories;
using FluentAssertions;
using Microsoft.Extensions.Logging;
using Moq;

namespace ARA.Application.Tests.Category;

/// <summary>
/// Tests for <see cref="CategoryService"/> covering retrieval and mapping of risk categories.
/// </summary>
public sealed class CategoryServiceTests
{
    private readonly Mock<ICategoryRepository> _categoryRepo = new();
    private readonly CategoryService _sut;

    public CategoryServiceTests()
    {
        _sut = new CategoryService(
            _categoryRepo.Object,
            Mock.Of<ILogger<CategoryService>>());
    }

    [Fact]
    public async Task GetAllAsync_WithCategories_ReturnsMappedDtos()
    {
        List<Domain.Entities.Category> categories =
        [
            new() { CategoryId = 1, CategoryName = "Award Fees", RiskLevel = 1, Color = "#00FF00" },
            new() { CategoryId = 2, CategoryName = "Pre-Contract Costs", RiskLevel = 3, Color = "#FF0000" },
        ];
        _categoryRepo.Setup(r => r.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(categories.AsReadOnly());

        IReadOnlyList<CategoryDto> result = await _sut.GetAllAsync(CancellationToken.None);

        result.Should().HaveCount(2);
        result[0].CategoryId.Should().Be(1);
        result[0].CategoryName.Should().Be("Award Fees");
        result[0].RiskLevel.Should().Be(1);
        result[0].Color.Should().Be("#00FF00");
        result[1].CategoryId.Should().Be(2);
        result[1].CategoryName.Should().Be("Pre-Contract Costs");
    }

    [Fact]
    public async Task GetByIdAsync_WithExistingCategory_ReturnsSuccessResult()
    {
        Domain.Entities.Category category = new()
        {
            CategoryId = 5,
            CategoryName = "Change in Scope",
            RiskLevel = 2,
            Color = "#FFAA00",
        };
        _categoryRepo.Setup(r => r.GetByIdAsync(5, It.IsAny<CancellationToken>()))
            .ReturnsAsync(category);

        Result<CategoryDto> result = await _sut.GetByIdAsync(5, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Value!.CategoryId.Should().Be(5);
        result.Value.CategoryName.Should().Be("Change in Scope");
        result.Value.RiskLevel.Should().Be(2);
        result.Value.Color.Should().Be("#FFAA00");
    }

    [Fact]
    public async Task GetByIdAsync_WithNonExistentCategory_ReturnsFailureResult()
    {
        _categoryRepo.Setup(r => r.GetByIdAsync(999, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Domain.Entities.Category?)null);

        Result<CategoryDto> result = await _sut.GetByIdAsync(999, CancellationToken.None);

        result.IsFailure.Should().BeTrue();
        result.Error.Should().NotBeNullOrEmpty();
    }
}
