namespace ARA.Domain.Entities;

/// <summary>
/// Stores the PM section narrative answers for an ARA.
/// Maps to the legacy <c>ara_PM</c> table. These are the questions whose display
/// is suppressed for ARA amounts at or below $50,000. The exact $50K applicability
/// per question is configurable via the <c>QuestionMap</c> table.
/// </summary>
public sealed class AraPmSection
{
    /// <summary>Gets the primary key. Maps to legacy <c>ara_PM_ID</c>.</summary>
    public int AraPmSectionId { get; init; }

    /// <summary>Gets the ID of the owning ARA. Maps to legacy <c>ara_ID</c>.</summary>
    public int AraId { get; init; }

    /// <summary>Gets the PM's answer regarding funds in advance. Maps to legacy <c>fundsInAdvance</c>.</summary>
    public string? FundsInAdvance { get; init; }

    /// <summary>Gets the PM's answer regarding contract definitization. Maps to legacy <c>contractDefinization</c>.</summary>
    public string? ContractDefinization { get; init; }

    /// <summary>Gets pertinent background information entered by the PM. Maps to legacy <c>pertinentInformation</c>.</summary>
    public string? PertinentInformation { get; init; }

    /// <summary>Gets the PM's explanation of work already started. Maps to legacy <c>workStarted</c>.</summary>
    public string? WorkStarted { get; init; }

    /// <summary>Gets the PM's description of consequences if ARA is not approved. Maps to legacy <c>consequence</c>.</summary>
    public string? Consequence { get; init; }

    /// <summary>Gets the current status narrative entered by the PM. Maps to legacy <c>currentStatus</c>.</summary>
    public string? CurrentStatus { get; init; }

    /// <summary>Gets the PM's description of any change in scope. Maps to legacy <c>changeInScope</c>.</summary>
    public string? ChangeInScope { get; init; }

    /// <summary>Gets the PM's described action to clear the at-risk condition. Maps to legacy <c>actionToClear</c>.</summary>
    public string? ActionToClear { get; init; }

    /// <summary>Gets the PM's answer to the Early Start necessity question. Maps to legacy <c>ES_Necessary</c>.</summary>
    public string? EarlyStartNecessary { get; init; }

    /// <summary>Gets the PM's answer to the other necessity question. Maps to legacy <c>Other_necessary</c>.</summary>
    public string? OtherNecessary { get; init; }
}
