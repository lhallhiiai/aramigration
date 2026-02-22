import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import * as clinService from "@/services/clinService";
import type { CreateClinRequest, UpdateClinRequest } from "@/types";

export function useClins(araId: number) {
  return useQuery({
    queryKey: ["clins", araId],
    queryFn: () => clinService.fetchClins(araId),
    enabled: araId > 0,
  });
}

export function useCreateClin(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (request: CreateClinRequest) => clinService.createClin(araId, request),
    onSuccess: () => {
      toast.success("CLIN entry added");
      qc.invalidateQueries({ queryKey: ["clins", araId] });
      qc.invalidateQueries({ queryKey: ["controller-section", araId] });
    },
    onError: (error: Error) => {
      toast.error(`Failed to add CLIN: ${error.message}`);
    },
  });
}

export function useUpdateClin(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (params: { clinEntryId: number; request: UpdateClinRequest }) =>
      clinService.updateClin(araId, params.clinEntryId, params.request),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["clins", araId] });
      qc.invalidateQueries({ queryKey: ["controller-section", araId] });
    },
    onError: (error: Error) => {
      toast.error(`Failed to update CLIN: ${error.message}`);
    },
  });
}

export function useDeleteClin(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (clinEntryId: number) => clinService.deleteClin(araId, clinEntryId),
    onSuccess: () => {
      toast.success("CLIN entry removed");
      qc.invalidateQueries({ queryKey: ["clins", araId] });
      qc.invalidateQueries({ queryKey: ["controller-section", araId] });
    },
    onError: (error: Error) => {
      toast.error(`Failed to remove CLIN: ${error.message}`);
    },
  });
}
