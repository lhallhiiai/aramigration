using ARA.Domain.Enums;

namespace ARA.Domain.Entities;

/// <summary>
/// Represents a system user with an assigned role in the ARA workflow.
/// Identity is federated through Microsoft Entra ID; local records store the
/// role assignment, approval routing configuration, and display information.
/// Maps to the legacy <c>users</c> table.
/// </summary>
public sealed class User
{
    /// <summary>Gets the unique local identifier for this user (primary key).</summary>
    public int UserId { get; init; }

    /// <summary>
    /// Gets the Microsoft Entra ID object identifier (OID claim) used to resolve the authenticated caller.
    /// Replaces the legacy <c>oprid</c> / <c>password</c> authentication model.
    /// </summary>
    public string EntraObjectId { get; init; } = string.Empty;

    /// <summary>Gets the HR system employee identifier. Maps to legacy <c>emplID</c>.</summary>
    public string? EmployeeId { get; init; }

    /// <summary>
    /// Gets the legacy PeopleSoft operator ID retained for migration reference only.
    /// Not used for authentication. Maps to legacy <c>oprid</c>.
    /// </summary>
    public string? LegacyOprid { get; init; }

    /// <summary>Gets the user's full display name. Maps to legacy <c>empname</c>.</summary>
    public string DisplayName { get; init; } = string.Empty;

    /// <summary>Gets the user's first name. Maps to legacy <c>first_name</c>.</summary>
    public string? FirstName { get; init; }

    /// <summary>Gets the user's last name. Maps to legacy <c>last_name</c>.</summary>
    public string? LastName { get; init; }

    /// <summary>Gets the user's email address.</summary>
    public string Email { get; init; } = string.Empty;

    /// <summary>
    /// Gets the foreign key to the <c>Role</c> table. Use <see cref="Role"/> for domain logic.
    /// Maps to legacy <c>ID_role</c>.
    /// </summary>
    public int RoleId { get; init; }

    /// <summary>Gets the user's ARA workflow role, derived from <see cref="RoleId"/>.</summary>
    public UserRole Role => (UserRole)RoleId;

    /// <summary>
    /// Gets the user's job title identifier, which drives approval routing via the Threshold matrix.
    /// CA = 2, Controller = 3, PM = 4; higher values represent approver levels sequenced by <c>appOrder</c>.
    /// Maps to legacy <c>ID_job</c>.
    /// </summary>
    public int? JobTitleId { get; init; }

    /// <summary>Gets the sector identifier this user belongs to. Maps to legacy <c>ID_sector</c>.</summary>
    public int? SectorId { get; init; }

    /// <summary>
    /// Gets the comma-separated list of org division codes this user is authorised to approve.
    /// The approval routing query matches ARAs whose <c>Division</c> is in this list.
    /// Maps to legacy <c>Approve_grp</c>.
    /// </summary>
    public string? ApprovalGroups { get; init; }

    /// <summary>Gets the operation code limiting this user's approval scope. Maps to legacy <c>Approve_op</c>.</summary>
    public string? ApprovalOperation { get; init; }

    /// <summary>Gets the division code limiting this user's approval scope. Maps to legacy <c>Approve_div</c>.</summary>
    public string? ApprovalDivision { get; init; }

    /// <summary>Gets whether this account is inactive. Maps to legacy <c>Inactive</c>.</summary>
    public bool IsInactive { get; init; }

    /// <summary>Gets the UTC timestamp when this user record was created.</summary>
    public DateTime CreatedAt { get; init; }

    /// <summary>Gets the UTC timestamp of the most recent update to this user record.</summary>
    public DateTime? UpdatedAt { get; init; }
}
