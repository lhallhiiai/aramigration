import { apiClient } from "@/lib/api-client";
import type { User } from "@/types";
import type { UserRole } from "@/types/enums";

export function fetchCurrentUser(): Promise<User> {
  return apiClient.get<User>("/users/me");
}

export function fetchAllUsers(): Promise<User[]> {
  return apiClient.get<User[]>("/users");
}

export function fetchUsersByRole(role: UserRole): Promise<User[]> {
  return apiClient.get<User[]>(`/users/by-role/${role}`);
}
