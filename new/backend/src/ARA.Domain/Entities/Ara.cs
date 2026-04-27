using ARA.Domain.Enums;

namespace ARA.Domain.Entities;

/// <summary>
/// The central aggregate for an At Risk Authorization.
/// Maps to the legacy <c>ara</c> table. PM questions, CA answers, and Controller
/// section data are stored in separate child entities (<see cref="AraPmSection"/>,
/// <see cref="AraCaSection"/>, <see cref="AraControllerSection"/>) to match the
/// legacy <c>ara_PM</c>, <c>ara_cm</c>, and <c>ara_con</c> tables.
/// </summary>
public sealed class Ara
{
    /// <summary>Gets the unique system-assigned identifier for this ARA (primary key).</summary>
    public int AraId { get; init; }

    // ── Category and status (FK → computed enum) ──────────────────────────────

    /// <summary>
    /// Gets the foreign key to the <c>Category</c> table. The category's <c>RiskLevel</c>
    /// drives the Approval Threshold Matrix lookup. Maps to legacy <c>id_cat</c>.
    /// </summary>
    public int CategoryId { get; init; }

    /// <summary>Gets the risk category, derived from <see cref="CategoryId"/>.</summary>
    public RiskCategory RiskCategory => (RiskCategory)CategoryId;

    /// <summary>
    /// Gets the foreign key to the <c>Status</c> table. Maps to legacy <c>id_status</c>.
    /// </summary>
    public int StatusId { get; init; }

    /// <summary>Gets the current lifecycle status of the ARA, derived from <see cref="StatusId"/>.</summary>
    public AraStatus Status => (AraStatus)StatusId;

    // ── User assignments ──────────────────────────────────────────────────────

    /// <summary>Gets the ID of the user who created the ARA record. Maps to legacy <c>id_user</c>.</summary>
    public int CreatedByUserId { get; init; }

    /// <summary>
    /// Gets the ID of the Program Manager responsible for this ARA.
    /// May differ from <see cref="CreatedByUserId"/> when a record is created on behalf of a PM.
    /// Maps to legacy <c>ID_PM</c>.
    /// </summary>
    public int ProgramManagerId { get; init; }

    /// <summary>Gets the ID of the assigned Contract Administrator. Maps to legacy <c>ID_Contract</c>.</summary>
    public int ContractAdministratorId { get; init; }

    /// <summary>Gets the ID of the assigned Controller. Maps to legacy <c>ID_Controller</c>.</summary>
    public int ControllerId { get; init; }

    /// <summary>Gets the ID of the Operations VP approver, if applicable. Maps to legacy <c>ID_OpsVP</c>.</summary>
    public int? OpsVpUserId { get; init; }

    // ── Identification ────────────────────────────────────────────────────────

    /// <summary>
    /// Gets the display reference number for this ARA (e.g. "00001234").
    /// Maps to legacy <c>reference</c>.
    /// </summary>
    public string? Reference { get; init; }

    /// <summary>
    /// Gets the revision counter. Starts at 1 on creation and increments by 1
    /// each time the ARA is rejected and resubmitted. Maps to legacy <c>revision</c>.
    /// </summary>
    public int Revision { get; init; }

    /// <summary>
    /// Gets the legacy JAMIS-assigned identifier. Retained for migration reference only;
    /// JAMIS is no longer used. Maps to legacy <c>jamisNo</c>.
    /// </summary>
    public string? JamisId { get; init; }

    // ── Org and contract fields ───────────────────────────────────────────────

    /// <summary>Gets the org division code used for approval routing. Maps to legacy <c>division</c>.</summary>
    public string? Division { get; init; }

    /// <summary>
    /// Gets the contract number, validated against local Costpoint-sourced data.
    /// Populated for Non-Early Start ARAs only. Maps to legacy <c>contractNo</c>.
    /// </summary>
    public string? ContractNumber { get; init; }

    /// <summary>Gets the delivery order number associated with the contract. Maps to legacy <c>doNo</c>.</summary>
    public string? DeliveryOrderNumber { get; init; }

    /// <summary>Gets the contract type (e.g. T&amp;M, FFP, Cost Plus). Maps to legacy <c>contractType</c>.</summary>
    public string? ContractType { get; init; }

    /// <summary>
    /// Gets the legacy OMS opportunity number. OMS is no longer used; field retained for
    /// legacy data compatibility. Maps to legacy <c>OMSNum</c>.
    /// </summary>
    public string? OmsNumber { get; init; }

    // ── ARA content fields ────────────────────────────────────────────────────

    /// <summary>Gets the ARA title. Maps to legacy <c>title</c>.</summary>
    public string? Title { get; init; }

    /// <summary>Gets the customer name. Maps to legacy <c>customerName</c>.</summary>
    public string? CustomerName { get; init; }

    /// <summary>
    /// Gets the total ARA amount set by the PM. Used for the CLIN funding cap soft warning
    /// and determines the approval routing threshold ($500K triggers additional approvers).
    /// Maps to legacy <c>amountTotal</c>.
    /// </summary>
    public decimal AmountTotal { get; init; }

    /// <summary>Gets the specific amount requested within the ARA. Maps to legacy <c>amountRequested</c>.</summary>
    public decimal? AmountRequested { get; init; }

    /// <summary>Gets the total anticipated amount. Maps to legacy <c>totalAnticipated</c>.</summary>
    public decimal? TotalAnticipated { get; init; }

    /// <summary>Gets the anticipated percentage of the total. Maps to legacy <c>percentAnticipated</c>.</summary>
    public double? PercentAnticipated { get; init; }

    /// <summary>
    /// Gets the foreign key to the <c>RevenueDescription</c> table, representing the ARA type
    /// (Authority to Spend Only, or Authority to Spend with Revenue Recognition).
    /// Maps to legacy <c>ID_Revenue</c>.
    /// </summary>
    public int? RevenueDescriptionId { get; init; }

    // ── Early Start fields ────────────────────────────────────────────────────

    /// <summary>
    /// Gets whether this is an Early Start ARA (Pre-Contract Costs risk category).
    /// True when <see cref="RiskCategory"/> is <see cref="RiskCategory.PreContractCosts"/>.
    /// Maps to legacy <c>isEarlyStart</c>.
    /// </summary>
    public bool IsEarlyStart { get; init; }

    /// <summary>Gets the foreign key to the <c>EarlyStartReason</c> lookup. Maps to legacy <c>ID_esReason</c>.</summary>
    public int? EarlyStartReasonId { get; init; }

    /// <summary>Gets free-text early start reason when the standard reason is "Other". Maps to legacy <c>esOther</c>.</summary>
    public string? EarlyStartReasonOther { get; init; }

    // ── Company and misc flags ────────────────────────────────────────────────

    /// <summary>
    /// Gets the company code. Retained from the legacy system for reference.
    /// Maps to legacy <c>company</c>.
    /// </summary>
    public string? Company { get; init; }

    /// <summary>Gets the Estimated at Completion flag. Maps to legacy <c>isEAC</c>.</summary>
    public string? IsEac { get; init; }

    // ── Lifecycle dates ───────────────────────────────────────────────────────

    /// <summary>Gets the ARA authorization start date. Maps to legacy <c>startDate</c>.</summary>
    public DateTime? StartDate { get; init; }

    /// <summary>
    /// Gets the expected expiration date, entered manually by the PM during creation.
    /// Displayed on the Dashboard. Automatic transition to Expired status occurs when
    /// the date is reached. No extension mechanism exists. Maps to legacy <c>expirationDate</c>.
    /// </summary>
    public DateTime? ExpirationDate { get; init; }

    /// <summary>Gets the UTC timestamp when this ARA record was created.</summary>
    public DateTime CreatedAt { get; init; }

    /// <summary>Gets the UTC timestamp of the most recent update to this ARA record.</summary>
    public DateTime UpdatedAt { get; init; }

    /// <summary>Gets the legacy UTC timestamp when the ARA was exported. JAMIS export is no longer used.</summary>
    public DateTime? ExportedAt { get; init; }

    /// <summary>Gets the UTC timestamp when the CA negated this ARA.</summary>
    public DateTime? NegatedAt { get; init; }

    /// <summary>Gets the UTC timestamp when the PM cancelled this ARA.</summary>
    public DateTime? CancelledAt { get; init; }
}
