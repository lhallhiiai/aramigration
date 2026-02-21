namespace ARA.Domain.Entities;

/// <summary>
/// Represents a job title / approval role level used to drive the Approval Threshold Matrix.
/// The <see cref="AppOrder"/> field determines the sequential position of this role in the
/// approval chain. Maps to the legacy <c>jobTitle</c> table.
/// </summary>
public sealed class JobTitle
{
    /// <summary>Gets the primary key. Maps to legacy <c>id_job</c>.</summary>
    public int JobTitleId { get; init; }

    /// <summary>Gets the display title of this role (e.g. "Group Manager"). Maps to legacy <c>title</c>.</summary>
    public string Title { get; init; } = string.Empty;

    /// <summary>Gets the description of this job title's responsibilities. Maps to legacy <c>description</c>.</summary>
    public string? Description { get; init; }

    /// <summary>
    /// Gets the sequential position of this role in the approval chain.
    /// Lower values act first. Null for non-approver roles (PM, CA, Controller).
    /// Maps to legacy <c>appOrder</c>.
    /// </summary>
    public int? AppOrder { get; init; }

    /// <summary>Gets whether this job title is inactive. Maps to legacy <c>inactive</c>.</summary>
    public bool IsInactive { get; init; }
}
