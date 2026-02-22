import { useQuery } from "@tanstack/react-query";
import * as jobTitleService from "@/services/jobTitleService";

export function useJobTitles() {
  return useQuery({
    queryKey: ["job-titles"],
    queryFn: jobTitleService.fetchJobTitles,
    staleTime: Infinity,
  });
}
