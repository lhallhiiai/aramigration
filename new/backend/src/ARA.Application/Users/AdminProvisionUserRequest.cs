namespace ARA.Application.Users;

/// <summary>
/// Request body for the admin user-provisioning endpoint.
/// Used to seed a user record before any sign-in (e.g. for background processes
/// that authenticate without going through the SPA, or to pre-populate a user
/// the admin knows is about to onboard).
/// </summary>
/// <param name="ExternalUserId">The Okta subject identifier (sub) for the user.</param>
/// <param name="Email">The user's email address.</param>
/// <param name="DisplayName">The user's full display name.</param>
/// <param name="FirstName">The user's first name, if known.</param>
/// <param name="LastName">The user's last name, if known.</param>
public sealed record AdminProvisionUserRequest(
    string ExternalUserId,
    string Email,
    string DisplayName,
    string? FirstName,
    string? LastName);
