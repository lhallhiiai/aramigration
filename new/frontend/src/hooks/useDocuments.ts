import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import * as documentService from "@/services/documentService";
import type { CreateDocumentRequest } from "@/types";

export function useDocuments(araId: number) {
  return useQuery({
    queryKey: ["documents", araId],
    queryFn: () => documentService.fetchDocuments(araId),
    enabled: araId > 0,
  });
}

export function useCreateDocument(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (request: CreateDocumentRequest) =>
      documentService.createDocument(araId, request),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["documents", araId] });
    },
  });
}

export function useDeleteDocument(araId: number) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (araDocumentId: number) =>
      documentService.deleteDocument(araId, araDocumentId),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["documents", araId] });
    },
  });
}
