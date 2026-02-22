export const AraStatus = {
  Draft: 1,
  PendingContractAdministrator: 2,
  PendingController: 3,
  PendingApproval: 4,
  Approved: 5,
  Exported: 6,
  Expired: 7,
  Negated: 8,
  Cancelled: 9,
} as const;
export type AraStatus = (typeof AraStatus)[keyof typeof AraStatus];

export const UserRole = {
  Creator: 1,
  ContractAdministrator: 2,
  Controller: 3,
  Approver: 4,
} as const;
export type UserRole = (typeof UserRole)[keyof typeof UserRole];

export const RiskCategory = {
  AwardFees: 1,
  ModPendingIncrementalFunding: 2,
  ModPendingExerciseOptionPeriod: 3,
  ModPendingNotExerciseOptionPeriod: 4,
  InternalCleared: 5,
  CommercialAtRisk: 6,
  ChangeInScope: 7,
  FixedPriceMod: 8,
  PreContractCosts: 9,
} as const;
export type RiskCategory = (typeof RiskCategory)[keyof typeof RiskCategory];

export const ApprovalActionType = {
  Review: 1,
  Approve: 2,
  Reject: 3,
} as const;
export type ApprovalActionType = (typeof ApprovalActionType)[keyof typeof ApprovalActionType];

export const AraType = {
  AuthorityToSpendOnly: 1,
  AuthorityToSpendWithRevenueRecognition: 2,
} as const;
export type AraType = (typeof AraType)[keyof typeof AraType];

export const AraTab = {
  ProgramManager: 1,
  ContractAdministrator: 2,
  Controller: 3,
} as const;
export type AraTab = (typeof AraTab)[keyof typeof AraTab];
