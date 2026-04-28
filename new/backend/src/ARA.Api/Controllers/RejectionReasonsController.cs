using ARA.Application.RejectionReason;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>Exposes rejection reason code lookup data.</summary>
[ApiController]
[Route("api/rejection-reasons")]
[Authorize]
public sealed class RejectionReasonsController : ControllerBase
{
    private readonly IRejectionReasonService _rejectionReasonService;
    private readonly ILogger<RejectionReasonsController> _logger;

    /// <summary>Initializes a new instance of <see cref="RejectionReasonsController"/>.</summary>
    public RejectionReasonsController(
        IRejectionReasonService rejectionReasonService,
        ILogger<RejectionReasonsController> logger)
    {
        _rejectionReasonService = rejectionReasonService;
        _logger = logger;
    }

    /// <summary>Returns all active rejection reason codes.</summary>
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        IReadOnlyList<RejectionReasonDto> reasons =
            await _rejectionReasonService.GetAllActiveAsync(cancellationToken);
        return Ok(reasons);
    }
}
