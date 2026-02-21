using ARA.Domain.Entities;

namespace ARA.Domain.Repositories;

/// <summary>
/// Defines data access operations for the <c>JobTitle</c> lookup table.
/// Job titles drive the Approval Threshold Matrix and determine the approval sequence.
/// All implementations must use parameterized stored procedures via Dapper.
/// </summary>
public interface IJobTitleRepository
{
    /// <summary>Retrieves all active job titles ordered by <c>AppOrder</c>.</summary>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<IReadOnlyList<JobTitle>> GetAllActiveAsync(CancellationToken cancellationToken = default);

    /// <summary>Retrieves a single job title by its identifier.</summary>
    /// <param name="jobTitleId">The job title primary key.</param>
    /// <param name="cancellationToken">Token to cancel the operation.</param>
    Task<JobTitle?> GetByIdAsync(int jobTitleId, CancellationToken cancellationToken = default);
}
