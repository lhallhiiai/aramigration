using ARA.Application.Common;
using ARA.Application.Users;
using ARA.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>
/// Administrative user-management endpoints. Currently exposes a single onboard
/// endpoint that pre-seeds a local <see cref="ARA.Domain.Entities.User"/> row
/// from a known Okta subject identifier, e.g. for background processes that
/// authenticate without going through the SPA, or to pre-populate a user the
/// admin knows is about to onboard.
///
/// <para>
/// Authorization model: per the Item 4 ship-plan decision, "Okta access = app
/// access" — any authenticated caller may invoke this endpoint. Tightening to
/// an admin-only role is tracked under the future role-management story.
/// </para>
/// </summary>
[ApiController]
[Route("api/admin/users")]
[Authorize]
public sealed class AdminUsersController : ControllerBase
{
    private readonly IUserProvisioningService _provisioningService;
    private readonly ILogger<AdminUsersController> _logger;

    /// <summary>Initializes a new instance of <see cref="AdminUsersController"/>.</summary>
    public AdminUsersController(
        IUserProvisioningService provisioningService,
        ILogger<AdminUsersController> logger)
    {
        _provisioningService = provisioningService;
        _logger = logger;
    }

    /// <summary>
    /// Pre-seeds a local user row for the supplied Okta subject identifier.
    /// Idempotent — if a row already exists for <see cref="AdminProvisionUserRequest.ExternalUserId"/>,
    /// returns the existing row unchanged. Otherwise creates a new row with the default RoleId
    /// (Creator/PM); role elevation is handled separately.
    /// </summary>
    [HttpPost("provision")]
    public async Task<IActionResult> Provision(
        [FromBody] AdminProvisionUserRequest request,
        CancellationToken cancellationToken)
    {
        Result<User> result = await _provisioningService.ProvisionAsync(
            request.ExternalUserId,
            request.Email,
            request.DisplayName,
            request.FirstName,
            request.LastName,
            cancellationToken);

        if (result.IsFailure)
        {
            return BadRequest(result.Error);
        }

        User user = result.Value!;
        return Ok(new
        {
            user.UserId,
            user.ExternalUserId,
            user.Email,
            user.DisplayName,
            user.FirstName,
            user.LastName,
            user.Role,
        });
    }
}
