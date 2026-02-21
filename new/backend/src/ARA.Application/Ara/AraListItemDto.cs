using ARA.Domain.Enums;

namespace ARA.Application.Ara;

/// <summary>
/// Compact ARA representation used in list views (My Action List, Dashboard, Search results).
/// Omits section data and approval history; those are fetched on the detail view.
/// </summary>
public sealed record AraListItemDto(
    int AraId,
    string? Reference,
    int Revision,
    int CategoryId,
    int StatusId,
    AraStatus Status,
    RiskCategory RiskCategory,
    string? Title,
    string? ContractNumber,
    string? OmsNumber,
    decimal AmountTotal,
    bool IsEarlyStart,
    DateTime? ExpirationDate,
    DateTime CreatedAt,
    int ProgramManagerId,
    int ContractAdministratorId,
    int ControllerId);
