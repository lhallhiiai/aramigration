import { useCurrentUser } from "./useUsers";
import { UserRole } from "@/types/enums";

export function useAuth() {
  const { data: user, isLoading, isError } = useCurrentUser();

  return {
    user,
    isLoading,
    isError,
    isCreator: user?.role === UserRole.Creator,
    isContractAdministrator: user?.role === UserRole.ContractAdministrator,
    isController: user?.role === UserRole.Controller,
    isApprover: user?.role === UserRole.Approver,
  };
}
