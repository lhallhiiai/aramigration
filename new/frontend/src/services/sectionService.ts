import { apiClient } from "@/lib/api-client";
import type {
  AraPmSection,
  SavePmSectionRequest,
  AraControllerSection,
  SaveControllerSectionRequest,
} from "@/types";

export function fetchPmSection(araId: number): Promise<AraPmSection> {
  return apiClient.get<AraPmSection>(`/aras/${araId}/pm-section`);
}

export function savePmSection(araId: number, request: SavePmSectionRequest): Promise<void> {
  return apiClient.put<void>(`/aras/${araId}/pm-section`, request);
}

export function fetchControllerSection(araId: number): Promise<AraControllerSection> {
  return apiClient.get<AraControllerSection>(`/aras/${araId}/controller-section`);
}

export function saveControllerSection(
  araId: number,
  request: SaveControllerSectionRequest,
): Promise<void> {
  return apiClient.put<void>(`/aras/${araId}/controller-section`, request);
}
