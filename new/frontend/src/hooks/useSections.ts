import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import * as sectionService from "@/services/sectionService";
import type { SavePmSectionRequest, SaveControllerSectionRequest } from "@/types";

export function usePmSection(araId: number) {
  return useQuery({
    queryKey: ["pm-section", araId],
    queryFn: () => sectionService.fetchPmSection(araId),
    enabled: araId > 0,
  });
}

export function useSavePmSection(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (request: SavePmSectionRequest) =>
      sectionService.savePmSection(araId, request),
    onSuccess: () => {
      toast.success("PM section saved");
      qc.invalidateQueries({ queryKey: ["pm-section", araId] });
    },
    onError: (error: Error) => {
      toast.error(`Failed to save PM section: ${error.message}`);
    },
  });
}

export function useControllerSection(araId: number) {
  return useQuery({
    queryKey: ["controller-section", araId],
    queryFn: () => sectionService.fetchControllerSection(araId),
    enabled: araId > 0,
  });
}

export function useSaveControllerSection(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (request: SaveControllerSectionRequest) =>
      sectionService.saveControllerSection(araId, request),
    onSuccess: () => {
      toast.success("Controller section saved");
      qc.invalidateQueries({ queryKey: ["controller-section", araId] });
    },
    onError: (error: Error) => {
      toast.error(`Failed to save controller section: ${error.message}`);
    },
  });
}
