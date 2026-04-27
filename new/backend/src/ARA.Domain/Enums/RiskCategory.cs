namespace ARA.Domain.Enums;

/// <summary>
/// Risk categories available when creating an ARA.
/// <see cref="PreContractCosts"/> is the sole Early Start category.
/// All other categories are Non-Early Start and use a Contract Number.
/// Categories map to Risk Levels (1=Low, 2=Medium, 3=High) which drive the Approval Matrix.
/// </summary>
public enum RiskCategory
{
    /// <summary>
    /// Non-Early Start: fees estimated as a percentage of costs incurred or revenue recognized;
    /// not funded until formally awarded by the customer.
    /// </summary>
    AwardFees = 1,

    /// <summary>
    /// Non-Early Start: pending modification to increase contract funding within the existing
    /// period of performance and contract ceiling.
    /// </summary>
    ModPendingIncrementalFunding = 2,

    /// <summary>
    /// Non-Early Start: pending modification to exercise an option period and increase funding.
    /// </summary>
    ModPendingExerciseOptionPeriod = 3,

    /// <summary>
    /// Non-Early Start: pending request to increase funding and extend the period of performance
    /// where the modification is not the exercise of an option period.
    /// </summary>
    ModPendingNotExerciseOptionPeriod = 4,

    /// <summary>
    /// Non-Early Start: risk condition was resolved after the report run date without customer
    /// involvement; normally cleared within 30 days or by end of the subsequent quarter.
    /// </summary>
    InternalCleared = 5,

    /// <summary>
    /// Non-Early Start: work requested by an existing commercial customer based on prior
    /// commercial practice, absent an executed T&amp;M or fixed price contract.
    /// </summary>
    CommercialAtRisk = 6,

    /// <summary>
    /// Non-Early Start: work involving a change in scope or statement of work on an existing
    /// cost reimbursement or T&amp;M contract.
    /// </summary>
    ChangeInScope = 7,

    /// <summary>
    /// Non-Early Start: request for an increase in the funding or value of a fixed price contract,
    /// including requests for equitable adjustment.
    /// </summary>
    FixedPriceMod = 8,

    /// <summary>
    /// Early Start (Risk Level 3 — High Risk): work performed in advance of a final negotiated
    /// contract where the customer has authorized HII in writing to proceed before contract
    /// definitization.
    /// </summary>
    PreContractCosts = 9,
}
