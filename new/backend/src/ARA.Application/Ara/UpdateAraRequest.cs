namespace ARA.Application.Ara;

/// <summary>
/// Payload for updating an existing ARA. All mutable fields are included;
/// identity, created-by, and terminal lifecycle timestamps are managed by the service.
/// </summary>
public sealed record UpdateAraRequest(
    int AraId,
    int CategoryId,
    int ProgramManagerId,
    int ContractAdministratorId,
    int ControllerId,
    int? OpsVpUserId,
    string? Reference,
    string? JamisId,
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
