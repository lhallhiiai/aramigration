using ARA.Domain.Enums;

namespace ARA.Application.Ara;

/// <summary>
/// Full ARA representation used on the detail / form view.
/// Section data (PM, CA, Controller) and CLIN entries are fetched via their own endpoints.
/// </summary>
public sealed record AraDetailDto(
    int AraId,
    string? Reference,
    int Revision,
    int CategoryId,
    RiskCategory RiskCategory,
    int StatusId,
    AraStatus Status,
    int CreatedByUserId,
    int ProgramManagerId,
    int ContractAdministratorId,
    int ControllerId,
    int? OpsVpUserId,
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
    DateTime? ExpirationDate,
    DateTime CreatedAt,
    DateTime UpdatedAt,
    DateTime? ExportedAt,
    DateTime? NegatedAt,
    DateTime? CancelledAt);
