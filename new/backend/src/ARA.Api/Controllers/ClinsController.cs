using ARA.Application.Clin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>Manages CLIN worksheet entries for an ARA (Non-Early Start ARAs only).</summary>
[ApiController]
[Route("api/aras/{araId:int}/clins")]
[Authorize]
public sealed class ClinsController : ControllerBase
{
    private readonly IClinEntryService _clinService;
    private readonly ILogger<ClinsController> _logger;

    /// <summary>Initializes a new instance of <see cref="ClinsController"/>.</summary>
    public ClinsController(IClinEntryService clinService, ILogger<ClinsController> logger)
    {
        _clinService = clinService;
        _logger = logger;
    }

    /// <summary>Returns all CLIN entries for the given ARA.</summary>
    [HttpGet]
    public async Task<IActionResult> GetByAraId(int araId, CancellationToken cancellationToken)
    {
        IReadOnlyList<ClinEntryDto> entries = await _clinService.GetByAraIdAsync(araId, cancellationToken);
        return Ok(entries);
    }

    /// <summary>Adds a new CLIN entry to the ARA. Returns the new ClinEntryId.</summary>
    [HttpPost]
    public async Task<IActionResult> Create(int araId, [FromBody] CreateClinRequest request, CancellationToken cancellationToken)
    {
        ARA.Application.Common.Result<int> result = await _clinService.CreateAsync(araId, request, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return Ok(result.Value);
    }

    /// <summary>Updates the Cost and Fee on an existing CLIN entry.</summary>
    [HttpPut("{clinEntryId:int}")]
    public async Task<IActionResult> Update(int araId, int clinEntryId, [FromBody] UpdateClinRequest request, CancellationToken cancellationToken)
    {
        if (clinEntryId != request.ClinEntryId)
            return BadRequest("Route ClinEntryId does not match request body ClinEntryId.");

        ARA.Application.Common.Result result = await _clinService.UpdateAsync(request, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }

    /// <summary>Returns CLIN summary totals with a soft warning flag if funding exceeds ARA amount.</summary>
    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary(int araId, CancellationToken cancellationToken)
    {
        ClinSummaryDto summary = await _clinService.GetSummaryAsync(araId, cancellationToken);
        return Ok(summary);
    }

    /// <summary>Removes a CLIN entry from the ARA.</summary>
    [HttpDelete("{clinEntryId:int}")]
    public async Task<IActionResult> Delete(int araId, int clinEntryId, CancellationToken cancellationToken)
    {
        ARA.Application.Common.Result result = await _clinService.DeleteAsync(clinEntryId, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }
}
