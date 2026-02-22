import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useUsersByRole, useAllUsers } from "@/hooks/useUsers";
import { UserRole } from "@/types/enums";
import { LoadingState } from "@/components/shared/LoadingState";

interface Step3RoleAssignmentProps {
  programManagerId: number;
  contractAdministratorId: number;
  controllerId: number;
  opsVpUserId: number | null;
  onChange: (updates: {
    programManagerId?: number;
    contractAdministratorId?: number;
    controllerId?: number;
    opsVpUserId?: number | null;
  }) => void;
  errors: Record<string, string | undefined>;
}

export function Step3RoleAssignment({
  programManagerId,
  contractAdministratorId,
  controllerId,
  opsVpUserId,
  onChange,
  errors,
}: Step3RoleAssignmentProps) {
  const { data: creators, isLoading: creatorsLoading } = useUsersByRole(
    UserRole.Creator,
  );
  const { data: cas, isLoading: casLoading } = useUsersByRole(
    UserRole.ContractAdministrator,
  );
  const { data: controllers, isLoading: controllersLoading } = useUsersByRole(
    UserRole.Controller,
  );
  const { data: allUsers, isLoading: allLoading } = useAllUsers();

  if (creatorsLoading || casLoading || controllersLoading || allLoading) {
    return <LoadingState rows={4} />;
  }

  return (
    <div className="space-y-6">
      <div>
        <Label className="text-base font-semibold">Assign Personnel</Label>
        <p className="mt-1 text-sm text-muted-foreground">
          Select the users responsible for each role in this ARA.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <div className="space-y-1.5">
          <Label>Program Manager *</Label>
          <Select
            value={programManagerId ? String(programManagerId) : ""}
            onValueChange={(val) =>
              onChange({ programManagerId: Number(val) })
            }
          >
            <SelectTrigger>
              <SelectValue placeholder="Select PM" />
            </SelectTrigger>
            <SelectContent>
              {creators?.map((u) => (
                <SelectItem key={u.userId} value={String(u.userId)}>
                  {u.displayName}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          {errors.programManagerId && (
            <p className="text-xs text-destructive">
              {errors.programManagerId}
            </p>
          )}
        </div>

        <div className="space-y-1.5">
          <Label>Contract Administrator *</Label>
          <Select
            value={
              contractAdministratorId
                ? String(contractAdministratorId)
                : ""
            }
            onValueChange={(val) =>
              onChange({ contractAdministratorId: Number(val) })
            }
          >
            <SelectTrigger>
              <SelectValue placeholder="Select CA" />
            </SelectTrigger>
            <SelectContent>
              {cas?.map((u) => (
                <SelectItem key={u.userId} value={String(u.userId)}>
                  {u.displayName}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          {errors.contractAdministratorId && (
            <p className="text-xs text-destructive">
              {errors.contractAdministratorId}
            </p>
          )}
        </div>

        <div className="space-y-1.5">
          <Label>Controller *</Label>
          <Select
            value={controllerId ? String(controllerId) : ""}
            onValueChange={(val) =>
              onChange({ controllerId: Number(val) })
            }
          >
            <SelectTrigger>
              <SelectValue placeholder="Select Controller" />
            </SelectTrigger>
            <SelectContent>
              {controllers?.map((u) => (
                <SelectItem key={u.userId} value={String(u.userId)}>
                  {u.displayName}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          {errors.controllerId && (
            <p className="text-xs text-destructive">
              {errors.controllerId}
            </p>
          )}
        </div>

        <div className="space-y-1.5">
          <Label>Ops VP (optional)</Label>
          <Select
            value={opsVpUserId ? String(opsVpUserId) : "none"}
            onValueChange={(val) =>
              onChange({
                opsVpUserId: val === "none" ? null : Number(val),
              })
            }
          >
            <SelectTrigger>
              <SelectValue placeholder="Select Ops VP" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="none">None</SelectItem>
              {allUsers?.map((u) => (
                <SelectItem key={u.userId} value={String(u.userId)}>
                  {u.displayName}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>
    </div>
  );
}
