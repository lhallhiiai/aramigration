using ARA.Application.Common;

namespace ARA.Application.Category;

/// <summary>Reads risk category reference data.</summary>
public interface ICategoryService
{
    /// <summary>Returns all risk categories ordered by CategoryId.</summary>
    Task<IReadOnlyList<CategoryDto>> GetAllAsync(CancellationToken cancellationToken = default);

    /// <summary>Returns a single category, or a failure result when not found.</summary>
    Task<Result<CategoryDto>> GetByIdAsync(int categoryId, CancellationToken cancellationToken = default);
}
