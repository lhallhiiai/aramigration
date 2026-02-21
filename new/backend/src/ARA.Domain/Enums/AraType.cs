namespace ARA.Domain.Enums;

/// <summary>
/// The two ARA authorization types as defined in the user guide.
/// Every ARA must be one of these two types; no others are permitted.
/// </summary>
public enum AraType
{
    /// <summary>Authorizes spending of company funds only; does not recognize associated revenue.</summary>
    AuthorityToSpendOnly = 1,

    /// <summary>Authorizes both spending of company funds and recognition of the associated revenue.</summary>
    AuthorityToSpendWithRevenueRecognition = 2,
}
