using ARA.Application.Ara;
using ARA.Application.Ara.Sections;
using ARA.Application.Approval;
using ARA.Application.Users;
using ARA.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>
/// Manages ARA records: CRUD, section data, and all workflow transitions.
/// All business rules are enforced in the service layer; this controller is intentionally thin.
/// </summary>
[ApiController]
[Route("api/aras")]
[Authorize]
public sealed class ArasController : ControllerBase
{
    private readonly IAraService _araService;
    private readonly IAraPmSectionService _pmSectionService;
    private readonly IAraControllerSectionService _controllerSectionService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<ArasController> _logger;

    /// <summary>Initializes a new instance of <see cref="ArasController"/>.</summary>
    public ArasController(
        IAraService araService,
        IAraPmSectionService pmSectionService,
        IAraControllerSectionService controllerSectionService,
        ICurrentUserService currentUserService,
        ILogger<ArasController> logger)
    {
        _araService               = araService;
        _pmSectionService         = pmSectionService;
        _controllerSectionService = controllerSectionService;
        _currentUserService       = currentUserService;
        _logger                   = logger;
    }

    // ── List endpoints ─────────────────────────────────────────────────────────

    /// <summary>Returns all active (non-terminal) ARAs.</summary>
    [HttpGet]
    public async Task<IActionResult> GetAllActive(CancellationToken cancellationToken)
    {
        IReadOnlyList<AraListItemDto> aras = await _araService.GetAllActiveAsync(cancellationToken);
        return Ok(aras);
    }

    /// <summary>Returns ARAs currently awaiting action from the authenticated user.</summary>
    [HttpGet("pending")]
    public async Task<IActionResult> GetPending(CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        IReadOnlyList<AraListItemDto> aras = await _araService.GetPendingForUserAsync(currentUser.UserId, cancellationToken);
        return Ok(aras);
    }

    /// <summary>Returns Exported and Negated ARAs accessible via the Archived menu.</summary>
    [HttpGet("archived")]
    public async Task<IActionResult> GetArchived(CancellationToken cancellationToken)
    {
        IReadOnlyList<AraListItemDto> aras = await _araService.GetArchivedAsync(cancellationToken);
        return Ok(aras);
    }

    /// <summary>Returns active ARAs sorted by expiration date for the Dashboard expirations view.</summary>
    [HttpGet("expirations")]
    public async Task<IActionResult> GetUpcomingExpirations(CancellationToken cancellationToken)
    {
        IReadOnlyList<AraListItemDto> aras = await _araService.GetUpcomingExpirationsAsync(cancellationToken);
        return Ok(aras);
    }

    /// <summary>Returns ARAs filtered by status. Drives Dashboard grouped-status views.</summary>
    [HttpGet("by-status/{status}")]
    public async Task<IActionResult> GetByStatus(AraStatus status, CancellationToken cancellationToken)
    {
        IReadOnlyList<AraListItemDto> aras = await _araService.GetByStatusAsync(status, cancellationToken);
        return Ok(aras);
    }

    /// <summary>Searches ARAs by partial or full ARA ID or JAMIS ID. Drives Quick Search.</summary>
    [HttpGet("search")]
    public async Task<IActionResult> Search([FromQuery] string q, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(q))
            return BadRequest("Search term is required.");

        IReadOnlyList<AraListItemDto> aras = await _araService.SearchAsync(q, cancellationToken);
        return Ok(aras);
    }

    // ── Detail ─────────────────────────────────────────────────────────────────

    /// <summary>Returns the full ARA detail record.</summary>
    [HttpGet("{araId:int}")]
    public async Task<IActionResult> GetById(int araId, CancellationToken cancellationToken)
    {
        AraDetailDto? ara = await _araService.GetByIdAsync(araId, cancellationToken);
        if (ara is null)
            return NotFound($"ARA {araId} not found.");
        return Ok(ara);
    }

    // ── CRUD ───────────────────────────────────────────────────────────────────

    /// <summary>Creates a new ARA in Draft status. Returns the new AraId.</summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateAraRequest request, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        ARA.Application.Common.Result<int> result = await _araService.CreateAsync(request, currentUser.UserId, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);

        return CreatedAtAction(nameof(GetById), new { araId = result.Value }, result.Value);
    }

    /// <summary>Updates the editable fields of an existing ARA.</summary>
    [HttpPut("{araId:int}")]
    public async Task<IActionResult> Update(int araId, [FromBody] UpdateAraRequest request, CancellationToken cancellationToken)
    {
        if (araId != request.AraId)
            return BadRequest("Route AraId does not match request body AraId.");

        ARA.Application.Common.Result result = await _araService.UpdateAsync(request, cancellationToken);
        if (result.IsFailure)
            return NotFound(result.Error);
        return NoContent();
    }

    // ── Section endpoints ──────────────────────────────────────────────────────

    /// <summary>Returns the PM narrative section for the given ARA.</summary>
    [HttpGet("{araId:int}/pm-section")]
    public async Task<IActionResult> GetPmSection(int araId, CancellationToken cancellationToken)
    {
        AraPmSectionDto? section = await _pmSectionService.GetByAraIdAsync(araId, cancellationToken);
        if (section is null)
            return NotFound($"PM section for ARA {araId} not found.");
        return Ok(section);
    }

    /// <summary>Creates or updates the PM narrative section for the given ARA.</summary>
    [HttpPut("{araId:int}/pm-section")]
    public async Task<IActionResult> SavePmSection(int araId, [FromBody] SaveAraPmSectionRequest request, CancellationToken cancellationToken)
    {
        ARA.Application.Common.Result result = await _pmSectionService.SaveAsync(araId, request, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }

    /// <summary>Returns the Controller section for the given ARA.</summary>
    [HttpGet("{araId:int}/controller-section")]
    public async Task<IActionResult> GetControllerSection(int araId, CancellationToken cancellationToken)
    {
        AraControllerSectionDto? section = await _controllerSectionService.GetByAraIdAsync(araId, cancellationToken);
        if (section is null)
            return NotFound($"Controller section for ARA {araId} not found.");
        return Ok(section);
    }

    /// <summary>Creates or updates the Controller section for the given ARA.</summary>
    [HttpPut("{araId:int}/controller-section")]
    public async Task<IActionResult> SaveControllerSection(int araId, [FromBody] SaveAraControllerSectionRequest request, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        ARA.Application.Common.Result result = await _controllerSectionService.SaveAsync(araId, currentUser.UserId, request, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }

    // ── Workflow transitions ────────────────────────────────────────────────────

    /// <summary>PM signs and submits the ARA. Transitions Draft → PendingContractAdministrator.</summary>
    [HttpPost("{araId:int}/submit-pm")]
    public async Task<IActionResult> SubmitByPm(int araId, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        ARA.Application.Common.Result result = await _araService.SubmitByPmAsync(araId, currentUser.UserId, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }

    /// <summary>CA submits the ARA forward. Transitions PendingContractAdministrator → PendingController.</summary>
    [HttpPost("{araId:int}/submit-ca")]
    public async Task<IActionResult> SubmitByCa(int araId, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        ARA.Application.Common.Result result = await _araService.SubmitByCaAsync(araId, currentUser.UserId, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }

    /// <summary>Controller submits the ARA for approval. Transitions PendingController → PendingApproval.</summary>
    [HttpPost("{araId:int}/submit-controller")]
    public async Task<IActionResult> SubmitByController(int araId, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        ARA.Application.Common.Result result = await _araService.SubmitByControllerAsync(araId, currentUser.UserId, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }

    /// <summary>Approver approves the ARA. Records the approval and transitions to Approved.</summary>
    [HttpPost("{araId:int}/approve")]
    public async Task<IActionResult> Approve(int araId, [FromBody] string? comment, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        ARA.Application.Common.Result result = await _araService.ApproveAsync(araId, currentUser.UserId, comment, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }

    /// <summary>Rejects the ARA at any workflow stage. Returns it to Draft and increments Revision.</summary>
    [HttpPost("{araId:int}/reject")]
    public async Task<IActionResult> Reject(int araId, [FromBody] RejectRequest request, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        ARA.Application.Common.Result result = await _araService.RejectAsync(araId, currentUser.UserId, request, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }

    /// <summary>PM cancels the ARA. Only the assigned PM may cancel non-terminal ARAs.</summary>
    [HttpPost("{araId:int}/cancel")]
    public async Task<IActionResult> Cancel(int araId, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        ARA.Application.Common.Result result = await _araService.CancelAsync(araId, currentUser.UserId, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }

    /// <summary>CA negates an Exported ARA after a contract modification is received.</summary>
    [HttpPost("{araId:int}/negate")]
    public async Task<IActionResult> Negate(int araId, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return NotFound("Current user not found in the database.");

        ARA.Application.Common.Result result = await _araService.NegateAsync(araId, currentUser.UserId, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return NoContent();
    }
}
