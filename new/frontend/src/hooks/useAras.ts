import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import * as araService from "@/services/araService";
import type { CreateAraRequest, UpdateAraRequest, RejectRequest } from "@/types";
import type { AraStatus } from "@/types/enums";

export function useActiveAras() {
  return useQuery({
    queryKey: ["aras", "active"],
    queryFn: araService.fetchAllActive,
  });
}

export function usePendingAras() {
  return useQuery({
    queryKey: ["aras", "pending"],
    queryFn: araService.fetchPending,
  });
}

export function useArchivedAras() {
  return useQuery({
    queryKey: ["aras", "archived"],
    queryFn: araService.fetchArchived,
  });
}

export function useExpirationAras() {
  return useQuery({
    queryKey: ["aras", "expirations"],
    queryFn: araService.fetchExpirations,
  });
}

export function useArasByStatus(status: AraStatus) {
  return useQuery({
    queryKey: ["aras", "by-status", status],
    queryFn: () => araService.fetchByStatus(status),
  });
}

export function useAraSearch(q: string) {
  return useQuery({
    queryKey: ["aras", "search", q],
    queryFn: () => araService.search(q),
    enabled: q.length >= 2,
  });
}

export function useAraDetail(araId: number) {
  return useQuery({
    queryKey: ["aras", araId],
    queryFn: () => araService.fetchDetail(araId),
    enabled: araId > 0,
  });
}

export function useCreateAra() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (request: CreateAraRequest) => araService.create(request),
    onSuccess: () => {
      toast.success("ARA created successfully");
      qc.invalidateQueries({ queryKey: ["aras"] });
    },
    onError: (error: Error) => {
      toast.error(`Failed to create ARA: ${error.message}`);
    },
  });
}

export function useUpdateAra(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (request: UpdateAraRequest) => araService.update(araId, request),
    onSuccess: () => {
      toast.success("ARA updated successfully");
      qc.invalidateQueries({ queryKey: ["aras"] });
    },
    onError: (error: Error) => {
      toast.error(`Failed to update ARA: ${error.message}`);
    },
  });
}

export function useSubmitByPm(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: () => araService.submitByPm(araId),
    onSuccess: () => {
      toast.success("ARA submitted to Contract Administrator");
      qc.invalidateQueries({ queryKey: ["aras"] });
    },
    onError: (error: Error) => {
      toast.error(`Submission failed: ${error.message}`);
    },
  });
}

export function useSubmitByCa(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: () => araService.submitByCa(araId),
    onSuccess: () => {
      toast.success("ARA submitted to Controller");
      qc.invalidateQueries({ queryKey: ["aras"] });
    },
    onError: (error: Error) => {
      toast.error(`Submission failed: ${error.message}`);
    },
  });
}

export function useSubmitByController(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: () => araService.submitByController(araId),
    onSuccess: () => {
      toast.success("ARA submitted for approval");
      qc.invalidateQueries({ queryKey: ["aras"] });
    },
    onError: (error: Error) => {
      toast.error(`Submission failed: ${error.message}`);
    },
  });
}

export function useApproveAra(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (comment?: string) => araService.approve(araId, comment),
    onSuccess: () => {
      toast.success("ARA approved");
      qc.invalidateQueries({ queryKey: ["aras"] });
    },
    onError: (error: Error) => {
      toast.error(`Approval failed: ${error.message}`);
    },
  });
}

export function useRejectAra(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (request: RejectRequest) => araService.reject(araId, request),
    onSuccess: () => {
      toast.success("ARA rejected and returned to PM");
      qc.invalidateQueries({ queryKey: ["aras"] });
    },
    onError: (error: Error) => {
      toast.error(`Rejection failed: ${error.message}`);
    },
  });
}

export function useCancelAra(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: () => araService.cancel(araId),
    onSuccess: () => {
      toast.success("ARA cancelled");
      qc.invalidateQueries({ queryKey: ["aras"] });
    },
    onError: (error: Error) => {
      toast.error(`Cancellation failed: ${error.message}`);
    },
  });
}

export function useNegateAra(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: () => araService.negate(araId),
    onSuccess: () => {
      toast.success("ARA negated");
      qc.invalidateQueries({ queryKey: ["aras"] });
    },
    onError: (error: Error) => {
      toast.error(`Negation failed: ${error.message}`);
    },
  });
}
