using ARA.Application.Users;
using ARA.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ARA.Api.Controllers;

/// <summary>Exposes user data used to populate assignment dropdowns on ARA forms.</summary>
[ApiController]
[Route("api/users")]
[Authorize]
public sealed class UsersController : ControllerBase
{
    private readonly IUserService _userService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<UsersController> _logger;

    /// <summary>Initializes a new instance of <see cref="UsersController"/>.</summary>
    public UsersController(
        IUserService userService,
        ICurrentUserService currentUserService,
        ILogger<UsersController> logger)
    {
        _userService        = userService;
        _currentUserService = currentUserService;
        _logger             = logger;
    }

    /// <summary>Returns the currently authenticated user, or 404 if not in the database.</summary>
    [HttpGet("me")]
    public async Task<IActionResult> GetCurrentUser(CancellationToken cancellationToken)
    {
        UserDto? user = await _currentUserService.GetCurrentUserAsync(cancellationToken);
        if (user is null)
            return NotFound("Current user not found in the database.");
        return Ok(user);
    }

    /// <summary>Returns all active users. Drives the PM assignment dropdown.</summary>
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken cancellationToken)
    {
        IReadOnlyList<UserDto> users = await _userService.GetAllActiveAsync(cancellationToken);
        return Ok(users);
    }

    /// <summary>Returns active users with the specified role. Drives CA and Controller assignment dropdowns.</summary>
    [HttpGet("by-role/{role}")]
    public async Task<IActionResult> GetByRole(UserRole role, CancellationToken cancellationToken)
    {
        IReadOnlyList<UserDto> users = await _userService.GetByRoleAsync(role, cancellationToken);
        return Ok(users);
    }
}
