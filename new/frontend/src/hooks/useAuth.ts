import { useOktaAuth } from "@okta/okta-react";
import { useCurrentUser } from "./useUsers";
import { UserRole } from "@/types/enums";

export function useAuth() {
  const { authState } = useOktaAuth();
  const { data: user, isLoading, isError } = useCurrentUser();

  return {
    user,
    isLoading: !authState || isLoading,
    isError,
    isAuthenticated: authState?.isAuthenticated ?? false,
    isCreator: user?.role === UserRole.Creator,
    isContractAdministrator: user?.role === UserRole.ContractAdministrator,
    isController: user?.role === UserRole.Controller,
    isApprover: user?.role === UserRole.Approver,
  };
}
