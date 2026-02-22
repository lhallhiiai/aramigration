import type { AraStatus, RiskCategory } from "./enums";

export interface AraListItem {
  araId: number;
  reference: string | null;
  revision: number;
  categoryId: number;
  statusId: number;
  status: AraStatus;
  riskCategory: RiskCategory;
  title: string | null;
  contractNumber: string | null;
  omsNumber: string | null;
  amountTotal: number;
  isEarlyStart: boolean;
  expirationDate: string | null;
  createdAt: string;
  programManagerId: number;
  contractAdministratorId: number;
  controllerId: number;
}

export interface AraDetail {
  araId: number;
  reference: string | null;
  revision: number;
  categoryId: number;
  riskCategory: RiskCategory;
  statusId: number;
  status: AraStatus;
  createdByUserId: number;
  programManagerId: number;
  contractAdministratorId: number;
  controllerId: number;
  opsVpUserId: number | null;
  jamisId: string | null;
  division: string | null;
  contractNumber: string | null;
  deliveryOrderNumber: string | null;
  contractType: string | null;
  omsNumber: string | null;
  title: string | null;
  customerName: string | null;
  amountTotal: number;
  amountRequested: number | null;
  totalAnticipated: number | null;
  percentAnticipated: number | null;
  revenueDescriptionId: number | null;
  isEarlyStart: boolean;
  earlyStartReasonId: number | null;
  earlyStartReasonOther: string | null;
  company: string | null;
  isEac: string | null;
  startDate: string | null;
  expirationDate: string | null;
  createdAt: string;
  updatedAt: string;
  exportedAt: string | null;
  negatedAt: string | null;
  cancelledAt: string | null;
}

export interface CreateAraRequest {
  categoryId: number;
  programManagerId: number;
  contractAdministratorId: number;
  controllerId: number;
  opsVpUserId: number | null;
  division: string | null;
  contractNumber: string | null;
  deliveryOrderNumber: string | null;
  contractType: string | null;
  omsNumber: string | null;
  title: string | null;
  customerName: string | null;
  amountTotal: number;
  amountRequested: number | null;
  totalAnticipated: number | null;
  percentAnticipated: number | null;
  revenueDescriptionId: number | null;
  isEarlyStart: boolean;
  earlyStartReasonId: number | null;
  earlyStartReasonOther: string | null;
  company: string | null;
  isEac: string | null;
  startDate: string | null;
  expirationDate: string | null;
}

export interface UpdateAraRequest {
  araId: number;
  categoryId: number;
  programManagerId: number;
  contractAdministratorId: number;
  controllerId: number;
  opsVpUserId: number | null;
  reference: string | null;
  jamisId: string | null;
  division: string | null;
  contractNumber: string | null;
  deliveryOrderNumber: string | null;
  contractType: string | null;
  omsNumber: string | null;
  title: string | null;
  customerName: string | null;
  amountTotal: number;
  amountRequested: number | null;
  totalAnticipated: number | null;
  percentAnticipated: number | null;
  revenueDescriptionId: number | null;
  isEarlyStart: boolean;
  earlyStartReasonId: number | null;
  earlyStartReasonOther: string | null;
  company: string | null;
  isEac: string | null;
  startDate: string | null;
  expirationDate: string | null;
}
