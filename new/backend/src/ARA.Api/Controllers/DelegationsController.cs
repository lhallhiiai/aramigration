using ARA.Application.Common;
using ARA.Application.Delegation;
using ARA.Application.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>Manages user delegation of approval authority.</summary>
[ApiController]
[Route("api/delegations")]
[Authorize]
public sealed class DelegationsController : ControllerBase
{
    private readonly IDelegationService _delegationService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<DelegationsController> _logger;

    /// <summary>Initializes a new instance of <see cref="DelegationsController"/>.</summary>
    public DelegationsController(
        IDelegationService delegationService,
        ICurrentUserService currentUserService,
        ILogger<DelegationsController> logger)
    {
        _delegationService  = delegationService;
        _currentUserService = currentUserService;
        _logger             = logger;
    }

    /// <summary>Returns all currently active delegations.</summary>
    [HttpGet]
    public async Task<IActionResult> GetActive(CancellationToken cancellationToken)
    {
        IReadOnlyList<DelegationDto> delegations =
            await _delegationService.GetActiveDelegationsAsync(cancellationToken);
        return Ok(delegations);
    }

    /// <summary>Creates a new delegation from the authenticated user to the specified delegatee.</summary>
    [HttpPost]
    public async Task<IActionResult> Create(
        [FromBody] CreateDelegationRequest request, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return Unauthorized();

        Result<int> result = await _delegationService.CreateDelegationAsync(request, currentUser.UserId, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);

        return CreatedAtAction(nameof(GetActive), new { }, new { DelegationId = result.Value });
    }

    /// <summary>Deactivates a delegation by ID.</summary>
    [HttpDelete("{delegationId:int}")]
    public async Task<IActionResult> Deactivate(int delegationId, CancellationToken cancellationToken)
    {
        UserDto? currentUser = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (currentUser is null)
            return Unauthorized();

        Result result = await _delegationService.DeactivateDelegationAsync(delegationId, currentUser.UserId, cancellationToken);
        if (result.IsFailure)
            return BadRequest(result.Error);

        return NoContent();
    }
}
