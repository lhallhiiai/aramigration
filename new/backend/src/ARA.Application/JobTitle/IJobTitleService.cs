namespace ARA.Application.JobTitle;

/// <summary>Reads job title reference data used for approval routing.</summary>
public interface IJobTitleService
{
    /// <summary>Returns all active job titles ordered by AppOrder then JobTitleId.</summary>
    Task<IReadOnlyList<JobTitleDto>> GetAllActiveAsync(CancellationToken cancellationToken = default);
}
