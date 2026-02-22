import { AraStatus, RiskCategory } from "@/types/enums";

const STATUS_LABELS: Record<number, string> = {
  [AraStatus.Draft]: "Draft",
  [AraStatus.PendingContractAdministrator]: "Pending Contract Administrator",
  [AraStatus.PendingController]: "Pending Controller",
  [AraStatus.PendingApproval]: "Pending Approval",
  [AraStatus.Approved]: "Approved",
  [AraStatus.Exported]: "Exported",
  [AraStatus.Expired]: "Expired",
  [AraStatus.Negated]: "Negated",
  [AraStatus.Cancelled]: "Cancelled",
};

const RISK_CATEGORY_LABELS: Record<number, string> = {
  [RiskCategory.AwardFees]: "Award Fees",
  [RiskCategory.ModPendingIncrementalFunding]: "Mod Pending (Incremental Funding)",
  [RiskCategory.ModPendingExerciseOptionPeriod]: "Mod Pending (Exercise Option Period)",
  [RiskCategory.ModPendingNotExerciseOptionPeriod]: "Mod Pending (Not Exercise Option Period)",
  [RiskCategory.InternalCleared]: "Internal Cleared",
  [RiskCategory.CommercialAtRisk]: "Commercial At-Risk",
  [RiskCategory.ChangeInScope]: "Change in Scope",
  [RiskCategory.FixedPriceMod]: "Fixed Price Mod",
  [RiskCategory.PreContractCosts]: "Pre-Contract Costs",
};

const TERMINAL_STATUSES: ReadonlySet<number> = new Set([
  AraStatus.Approved,
  AraStatus.Exported,
  AraStatus.Expired,
  AraStatus.Negated,
  AraStatus.Cancelled,
]);

export function getStatusLabel(status: AraStatus): string {
  return STATUS_LABELS[status] ?? `Unknown (${status})`;
}

export function getRiskCategoryLabel(category: RiskCategory): string {
  return RISK_CATEGORY_LABELS[category] ?? `Unknown (${category})`;
}

export function isTerminalStatus(status: AraStatus): boolean {
  return TERMINAL_STATUSES.has(status);
}

export function getStatusVariant(
  status: AraStatus,
): "default" | "secondary" | "destructive" | "outline" {
  switch (status) {
    case AraStatus.Draft:
      return "secondary";
    case AraStatus.PendingContractAdministrator:
    case AraStatus.PendingController:
    case AraStatus.PendingApproval:
      return "default";
    case AraStatus.Approved:
    case AraStatus.Exported:
      return "outline";
    case AraStatus.Expired:
    case AraStatus.Negated:
    case AraStatus.Cancelled:
      return "destructive";
    default:
      return "secondary";
  }
}
