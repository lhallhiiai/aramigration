namespace ARA.Domain.Enums;

/// <summary>
/// The action an Approver may take on an ARA at the approval stage.
/// </summary>
public enum ApprovalActionType
{
    /// <summary>
    /// Approver reviewed the ARA in read-only mode. Does not advance or return the ARA.
    /// </summary>
    Review = 1,

    /// <summary>
    /// Approver approved the ARA. Routes to the next approver per the Approval and Threshold
    /// Matrix, or marks the ARA as fully approved if no further approvers are required.
    /// </summary>
    Approve = 2,

    /// <summary>
    /// Approver rejected the ARA. Returns the ARA to the PM's queue and restarts the
    /// entire action chain from the beginning.
    /// </summary>
    Reject = 3,
}
