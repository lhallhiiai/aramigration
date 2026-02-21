namespace ARA.Domain.Enums;

/// <summary>
/// System roles in the ARA workflow. Each role has distinct permissions and
/// sequential responsibilities in the approval chain.
/// </summary>
public enum UserRole
{
    /// <summary>
    /// Creates ARAs and completes the PM section. Only users with this role may
    /// access the Create ARA function. Only Creators may cancel an in-progress ARA.
    /// </summary>
    Creator = 1,

    /// <summary>
    /// Reviews the ARA after PM submission, answers questions, uploads documents
    /// (required for Non-Early Start; optional for Early Start), and submits forward or rejects.
    /// Only the CA may negate an Exported ARA.
    /// </summary>
    ContractAdministrator = 2,

    /// <summary>
    /// Reviews the ARA after CA submission, completes the CLIN worksheet (Non-Early Start only),
    /// uploads supporting documents, and submits for approval or rejects.
    /// </summary>
    Controller = 3,

    /// <summary>
    /// Reviews and approves or rejects the ARA per the Approval and Threshold Matrix.
    /// May also review the ARA in read-only mode without taking a final decision.
    /// </summary>
    Approver = 4,
}
