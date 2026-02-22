import type { ApprovalActionType } from "./enums";

export interface ApprovalRecord {
  approvalRecordId: number;
  araId: number;
  approverId: number | null;
  jobTitleId: number | null;
  action: ApprovalActionType;
  sequenceOrder: number;
  comment: string | null;
  rejectionReasonId: number | null;
  rejectionAreas: string | null;
  actionTakenAt: string;
  araRevision: number;
}

export interface RejectRequest {
  comment: string;
  rejectionReasonId: number | null;
  rejectionAreas: string | null;
}
