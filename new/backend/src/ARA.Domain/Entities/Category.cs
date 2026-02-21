namespace ARA.Domain.Entities;

/// <summary>
/// Represents a risk category that an ARA can be assigned to.
/// The <see cref="RiskLevel"/> value links this category to the Approval Threshold Matrix.
/// Maps to the legacy <c>category</c> table.
/// </summary>
public sealed class Category
{
    /// <summary>Gets the primary key. Maps to legacy <c>id_cat</c>.</summary>
    public int CategoryId { get; init; }

    /// <summary>Gets the display name of the category (e.g. "Award Fees"). Maps to legacy <c>catName</c>.</summary>
    public string CategoryName { get; init; } = string.Empty;

    /// <summary>
    /// Gets the risk level integer used to join against the <c>Threshold</c> table.
    /// Multiple categories may share the same risk level. Maps to legacy <c>riskLevel</c>.
    /// </summary>
    public int RiskLevel { get; init; }

    /// <summary>Gets the display color used by the UI for this category. Maps to legacy <c>color</c>.</summary>
    public string? Color { get; init; }
}
