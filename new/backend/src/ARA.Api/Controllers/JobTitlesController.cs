using ARA.Application.JobTitle;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>Exposes job title lookup data used for approval routing.</summary>
[ApiController]
[Route("api/job-titles")]
[Authorize]
public sealed class JobTitlesController : ControllerBase
{
    private readonly IJobTitleService _jobTitleService;
    private readonly ILogger<JobTitlesController> _logger;

    /// <summary>Initializes a new instance of <see cref="JobTitlesController"/>.</summary>
    public JobTitlesController(IJobTitleService jobTitleService, ILogger<JobTitlesController> logger)
    {
        _jobTitleService = jobTitleService;
        _logger = logger;
    }

    /// <summary>Returns all active job titles ordered by display order.</summary>
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        IReadOnlyList<JobTitleDto> jobTitles = await _jobTitleService.GetAllActiveAsync(cancellationToken);
        return Ok(jobTitles);
    }
}
