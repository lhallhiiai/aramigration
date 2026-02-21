using ARA.Application.Approval;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>Exposes the read-only approval history (Approval Cycle) for an ARA.</summary>
[ApiController]
[Route("api/aras/{araId:int}/approvals")]
[Authorize]
public sealed class ApprovalController : ControllerBase
{
    private readonly IApprovalRecordService _approvalService;
    private readonly ILogger<ApprovalController> _logger;

    /// <summary>Initializes a new instance of <see cref="ApprovalController"/>.</summary>
    public ApprovalController(IApprovalRecordService approvalService, ILogger<ApprovalController> logger)
    {
        _approvalService = approvalService;
        _logger          = logger;
    }

    /// <summary>
    /// Returns all approval records for the given ARA.
    /// Pass <paramref name="revision"/> to scope results to a specific submission cycle.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetByAraId(int araId, [FromQuery] int? revision, CancellationToken cancellationToken)
    {
        IReadOnlyList<ApprovalRecordDto> records = revision.HasValue
            ? await _approvalService.GetByAraIdAndRevisionAsync(araId, revision.Value, cancellationToken)
            : await _approvalService.GetByAraIdAsync(araId, cancellationToken);

        return Ok(records);
    }
}
