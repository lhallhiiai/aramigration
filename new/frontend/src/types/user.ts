import type { UserRole } from "./enums";

export interface User {
  userId: number;
  displayName: string;
  firstName: string | null;
  lastName: string | null;
  email: string;
  role: UserRole;
  jobTitleId: number | null;
}
