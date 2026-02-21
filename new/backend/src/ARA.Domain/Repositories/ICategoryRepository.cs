using ARA.Domain.Entities;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for the <c>Category</c> lookup table.
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface ICategoryRepository
{
    /// <summary>Retrieves all risk categories.</summary>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<Category>> GetAllAsync(CancellationToken cancellationToken = default);

    /// <summary>Retrieves a single category by its identifier.</summary>
    /// <param name="categoryId">The category primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<Category?> GetByIdAsync(int categoryId, CancellationToken cancellationToken = default);
}
