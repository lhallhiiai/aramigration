import { apiClient } from "@/lib/api-client";
import type { ClinEntry, CreateClinRequest, UpdateClinRequest } from "@/types";

export function fetchClins(araId: number): Promise<ClinEntry[]> {
  return apiClient.get<ClinEntry[]>(`/aras/${araId}/clins`);
}

export function createClin(araId: number, request: CreateClinRequest): Promise<number> {
  return apiClient.post<number>(`/aras/${araId}/clins`, request);
}

export function updateClin(araId: number, clinEntryId: number, request: UpdateClinRequest): Promise<void> {
  return apiClient.put<void>(`/aras/${araId}/clins/${clinEntryId}`, request);
}

export function deleteClin(araId: number, clinEntryId: number): Promise<void> {
  return apiClient.delete<void>(`/aras/${araId}/clins/${clinEntryId}`);
}
