using ARA.Domain.Repositories;
using Microsoft.Extensions.Logging;

namespace ARA.Application.JobTitle;

/// <summary>Reads job title reference data from the repository.</summary>
public sealed class JobTitleService : IJobTitleService
{
    private readonly IJobTitleRepository _repository;
    private readonly ILogger<JobTitleService> _logger;

    /// <summary>Initializes a new instance of <see cref="JobTitleService"/>.</summary>
    public JobTitleService(IJobTitleRepository repository, ILogger<JobTitleService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<IReadOnlyList<JobTitleDto>> GetAllActiveAsync(CancellationToken cancellationToken = default)
    {
        IReadOnlyList<ARA.Domain.Entities.JobTitle> titles =
            await _repository.GetAllActiveAsync(cancellationToken);
        return titles.Select(j => new JobTitleDto(j.JobTitleId, j.Title, j.Description, j.AppOrder))
                     .ToList()
                     .AsReadOnly();
    }
}
