using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>
/// Provides environment information to the frontend for display in the environment banner.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public sealed class EnvironmentController : ControllerBase
{
    private readonly IConfiguration _configuration;

    /// <summary>Initializes a new instance of <see cref="EnvironmentController"/>.</summary>
    public EnvironmentController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    /// <summary>
    /// Gets the current environment name (Development, Test, Production).
    /// </summary>
    /// <returns>Environment information.</returns>
    [HttpGet]
    [AllowAnonymous] // Allow unauthenticated access for environment info
    public ActionResult<EnvironmentInfoDto> GetEnvironmentInfo()
    {
        string environmentName = _configuration["Environment:Name"] ?? "Unknown";

        return Ok(new EnvironmentInfoDto
        {
            Name = environmentName
        });
    }
}
