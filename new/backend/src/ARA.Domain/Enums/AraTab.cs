namespace ARA.Domain.Enums;

/// <summary>
/// Identifies a section (tab) of the ARA form. Used by approvers to flag which
/// section should receive resubmission focus when rejecting an ARA.
/// </summary>
public enum AraTab
{
    /// <summary>The Program Manager section of the ARA form.</summary>
    ProgramManager = 1,

    /// <summary>The Contract Administrator section of the ARA form.</summary>
    ContractAdministrator = 2,

    /// <summary>The Controller section of the ARA form, including the CLIN worksheet.</summary>
    Controller = 3,

    /// <summary>The Documents section of the ARA form (uploaded PDF attachments).</summary>
    Documents = 4,
}
