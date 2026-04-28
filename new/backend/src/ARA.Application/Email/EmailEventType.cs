namespace ARA.Application.Email;

/// <summary>
/// Defines the workflow events that trigger email notifications.
/// Values align with the EmailType seed data in the database.
/// </summary>
public enum EmailEventType
{
    /// <summary>PM has signed and submitted the ARA.</summary>
    PmSubmitted = 1,

    /// <summary>Contract Administrator has submitted the ARA for next approval.</summary>
    CaSubmitted = 2,

    /// <summary>Controller has submitted the ARA for approval.</summary>
    ControllerSubmitted = 3,

    /// <summary>An approver has approved the ARA.</summary>
    ApproverApproved = 4,

    /// <summary>The ARA has been rejected and returned to the PM.</summary>
    Rejected = 5,

    /// <summary>The ARA has been negated by the Contract Administrator.</summary>
    Negated = 6,

    /// <summary>The ARA has been cancelled by the PM.</summary>
    Cancelled = 7,
}
