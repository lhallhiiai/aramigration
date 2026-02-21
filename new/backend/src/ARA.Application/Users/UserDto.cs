using ARA.Domain.Enums;

namespace ARA.Application.Users;

/// <summary>User record returned to the client.</summary>
public sealed record UserDto(
    int UserId,
    string DisplayName,
    string? FirstName,
    string? LastName,
    string Email,
    UserRole Role,
    int? JobTitleId);
