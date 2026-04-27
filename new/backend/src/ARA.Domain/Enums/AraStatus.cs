namespace ARA.Domain.Enums;

/// <summary>
/// Represents the lifecycle status of an At Risk Authorization.
/// </summary>
public enum AraStatus
{
    /// <summary>ARA has been created by the PM but not yet saved or submitted.</summary>
    Draft = 1,

    /// <summary>PM has signed and submitted; awaiting Contract Administrator action.</summary>
    PendingContractAdministrator = 2,

    /// <summary>CA has submitted; awaiting Controller action.</summary>
    PendingController = 3,

    /// <summary>Controller has submitted; awaiting approver action per the Approval and Threshold Matrix.</summary>
    PendingApproval = 4,

    /// <summary>All required approvers have approved the ARA.</summary>
    Approved = 5,

    /// <summary>Legacy status — JAMIS export is no longer used. Retained for historical data compatibility.</summary>
    Exported = 6,

    /// <summary>ARA authorization period lapsed without a contract modification being received.</summary>
    Expired = 7,

    /// <summary>CA negated a previously exported ARA after a contract modification was received post-export.</summary>
    Negated = 8,

    /// <summary>PM cancelled the ARA before the approval process was complete.</summary>
    Cancelled = 9,
}
