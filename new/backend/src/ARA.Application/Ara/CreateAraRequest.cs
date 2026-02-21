namespace ARA.Application.Ara;

/// <summary>
/// Payload for creating a new ARA. The record starts in Draft status.
/// ProgramManagerId may differ from the authenticated caller when a record
/// is created on behalf of another PM.
/// </summary>
public sealed record CreateAraRequest(
    int CategoryId,
    int ProgramManagerId,
    int ContractAdministratorId,
    int ControllerId,
    int? OpsVpUserId,
    string? Division,
    string? ContractNumber,
    string? DeliveryOrderNumber,
    string? ContractType,
    string? OmsNumber,
    string? Title,
    string? CustomerName,
    decimal AmountTotal,
    decimal? AmountRequested,
    decimal? TotalAnticipated,
    double? PercentAnticipated,
    int? RevenueDescriptionId,
    bool IsEarlyStart,
    int? EarlyStartReasonId,
    string? EarlyStartReasonOther,
    string? Company,
    string? IsEac,
    DateTime? StartDate,
    DateTime? ExpirationDate);
