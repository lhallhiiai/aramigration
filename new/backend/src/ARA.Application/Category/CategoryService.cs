using ARA.Application.Common;
using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.Category;

/// <summary>Reads risk category reference data from the repository.</summary>
public sealed class CategoryService : ICategoryService
{
    private readonly ICategoryRepository _repository;
    private readonly ILogger<CategoryService> _logger;

    /// <summary>Initializes a new instance of <see cref="CategoryService"/>.</summary>
    public CategoryService(ICategoryRepository repository, ILogger<CategoryService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<CategoryDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        IReadOnlyList<ARA.Domain.Entities.Category> categories =
            await _repository.GetAllAsync(cancellationToken);
        return categories.Select(ToDto).ToList().AsReadOnly();
    }

    /// <inheritdoc/>
    public async Task<Result<CategoryDto>> GetByIdAsync(int categoryId, CancellationToken cancellationToken = default)
    {
        ARA.Domain.Entities.Category? category =
            await _repository.GetByIdAsync(categoryId, cancellationToken);

        if (category is null)
        {
            _logger.LogWarning("Category {CategoryId} not found", categoryId);
            return Result<CategoryDto>.Failure($"Category {categoryId} not found.");
        }

        return Result<CategoryDto>.Success(ToDto(category));
    }

    private static CategoryDto ToDto(ARA.Domain.Entities.Category c) =>
        new(c.CategoryId, c.CategoryName, c.RiskLevel, c.Color);
}
