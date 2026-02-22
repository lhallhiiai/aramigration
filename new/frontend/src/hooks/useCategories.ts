import { useQuery } from "@tanstack/react-query";
import * as categoryService from "@/services/categoryService";

export function useCategories() {
  return useQuery({
    queryKey: ["categories"],
    queryFn: categoryService.fetchCategories,
    staleTime: Infinity,
  });
}
