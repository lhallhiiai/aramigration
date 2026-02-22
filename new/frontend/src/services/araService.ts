import { apiClient } from "@/lib/api-client";
import type { AraListItem, AraDetail, CreateAraRequest, UpdateAraRequest, RejectRequest } from "@/types";
import type { AraStatus } from "@/types/enums";

export function fetchAllActive(): Promise<AraListItem[]> {
  return apiClient.get<AraListItem[]>("/aras");
}

export function fetchPending(): Promise<AraListItem[]> {
  return apiClient.get<AraListItem[]>("/aras/pending");
}

export function fetchArchived(): Promise<AraListItem[]> {
  return apiClient.get<AraListItem[]>("/aras/archived");
}

export function fetchExpirations(): Promise<AraListItem[]> {
  return apiClient.get<AraListItem[]>("/aras/expirations");
}

export function fetchByStatus(status: AraStatus): Promise<AraListItem[]> {
  return apiClient.get<AraListItem[]>(`/aras/by-status/${status}`);
}

export function search(q: string): Promise<AraListItem[]> {
  return apiClient.get<AraListItem[]>(`/aras/search?q=${encodeURIComponent(q)}`);
}

export function fetchDetail(araId: number): Promise<AraDetail> {
  return apiClient.get<AraDetail>(`/aras/${araId}`);
}

export function create(request: CreateAraRequest): Promise<number> {
  return apiClient.post<number>("/aras", request);
}

export function update(araId: number, request: UpdateAraRequest): Promise<void> {
  return apiClient.put<void>(`/aras/${araId}`, request);
}

export function submitByPm(araId: number): Promise<void> {
  return apiClient.post<void>(`/aras/${araId}/submit-pm`);
}

export function submitByCa(araId: number): Promise<void> {
  return apiClient.post<void>(`/aras/${araId}/submit-ca`);
}

export function submitByController(araId: number): Promise<void> {
  return apiClient.post<void>(`/aras/${araId}/submit-controller`);
}

export function approve(araId: number, comment?: string): Promise<void> {
  return apiClient.post<void>(`/aras/${araId}/approve`, comment ?? null);
}

export function reject(araId: number, request: RejectRequest): Promise<void> {
  return apiClient.post<void>(`/aras/${araId}/reject`, request);
}

export function cancel(araId: number): Promise<void> {
  return apiClient.post<void>(`/aras/${araId}/cancel`);
}

export function negate(araId: number): Promise<void> {
  return apiClient.post<void>(`/aras/${araId}/negate`);
}
