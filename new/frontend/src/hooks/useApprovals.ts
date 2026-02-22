import { useQuery } from "@tanstack/react-query";
import * as approvalService from "@/services/approvalService";

export function useApprovals(araId: number, revision?: number) {
  return useQuery({
    queryKey: ["approvals", araId, revision],
    queryFn: () => approvalService.fetchApprovals(araId, revision),
    enabled: araId > 0,
  });
}
