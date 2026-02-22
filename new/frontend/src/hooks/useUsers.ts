import { useQuery } from "@tanstack/react-query";
import * as userService from "@/services/userService";
import type { UserRole } from "@/types/enums";

export function useCurrentUser() {
  return useQuery({
    queryKey: ["users", "me"],
    queryFn: userService.fetchCurrentUser,
  });
}

export function useAllUsers() {
  return useQuery({
    queryKey: ["users", "all"],
    queryFn: userService.fetchAllUsers,
  });
}

export function useUsersByRole(role: UserRole) {
  return useQuery({
    queryKey: ["users", "by-role", role],
    queryFn: () => userService.fetchUsersByRole(role),
  });
}
