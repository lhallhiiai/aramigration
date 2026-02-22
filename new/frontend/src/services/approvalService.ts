import { apiClient } from "@/lib/api-client";
import type { ApprovalRecord } from "@/types";

export function fetchApprovals(araId: number, revision?: number): Promise<ApprovalRecord[]> {
  const params = revision !== undefined ? `?revision=${revision}` : "";
  return apiClient.get<ApprovalRecord[]>(`/aras/${araId}/approvals${params}`);
}
