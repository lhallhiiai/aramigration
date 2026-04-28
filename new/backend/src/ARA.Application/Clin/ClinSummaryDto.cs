namespace ARA.Application.Clin;

/// <summary>
/// CLIN worksheet summary with totals and a soft warning flag.
/// The warning is triggered when the combined CLIN funding exceeds the ARA amount
/// set by the PM. Per business rules, this is a soft warning — the Controller may
/// proceed with acknowledgement.
/// </summary>
public sealed record ClinSummaryDto(
    decimal TotalCost,
    decimal TotalFee,
    decimal GrandTotal,
    decimal AraAmount,
    bool ExceedsAraAmount);
