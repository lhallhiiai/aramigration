using ARA.Domain.Enums;

namespace ARA.Domain.Entities;

/// <summary>
/// Represents a system user with an assigned role in the ARA workflow.
/// User identity is federated through Microsoft Entra ID; local records
/// store the role assignment and display information.
/// </summary>
public sealed class User
{
    /// <summary>Gets the unique local identifier for this user (primary key).</summary>
    public int UserId { get; init; }

    /// <summary>Gets the Microsoft Entra ID object identifier for this user.</summary>
    public string EntraObjectId { get; init; } = string.Empty;

    /// <summary>Gets the user's full display name.</summary>
    public string DisplayName { get; init; } = string.Empty;

    /// <summary>Gets the user's email address.</summary>
    public string Email { get; init; } = string.Empty;

    /// <summary>Gets the user's role in the ARA workflow.</summary>
    public UserRole Role { get; init; }

    /// <summary>Gets whether this user account is active and may log in.</summary>
    public bool IsActive { get; init; }

    /// <summary>Gets the UTC timestamp when this user record was created.</summary>
    public DateTime CreatedAt { get; init; }
}
