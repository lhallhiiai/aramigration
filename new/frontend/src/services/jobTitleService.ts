import { apiClient } from "@/lib/api-client";
import type { JobTitle } from "@/types";

export function fetchJobTitles(): Promise<JobTitle[]> {
  return apiClient.get<JobTitle[]>("/job-titles");
}
