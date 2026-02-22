import { apiClient } from "@/lib/api-client";
import type { AraDocument, CreateDocumentRequest } from "@/types";

export function fetchDocuments(araId: number): Promise<AraDocument[]> {
  return apiClient.get<AraDocument[]>(`/aras/${araId}/documents`);
}

export function createDocument(araId: number, request: CreateDocumentRequest): Promise<number> {
  return apiClient.post<number>(`/aras/${araId}/documents`, request);
}

export function deleteDocument(araId: number, araDocumentId: number): Promise<void> {
  return apiClient.delete<void>(`/aras/${araId}/documents/${araDocumentId}`);
}
