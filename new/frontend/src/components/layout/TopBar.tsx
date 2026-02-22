import { SidebarTrigger } from "@/components/ui/sidebar";
import { Separator } from "@/components/ui/separator";
import { Badge } from "@/components/ui/badge";
import { QuickSearch } from "./QuickSearch";
import { useAuth } from "@/hooks/useAuth";
import { UserRole } from "@/types/enums";

const ROLE_LABELS: Record<number, string> = {
  [UserRole.Creator]: "Creator",
  [UserRole.ContractAdministrator]: "Contract Admin",
  [UserRole.Controller]: "Controller",
  [UserRole.Approver]: "Approver",
};

export function TopBar() {
  const { user } = useAuth();

  return (
    <header className="flex h-14 items-center gap-4 border-b bg-background px-4">
      <SidebarTrigger />
      <Separator orientation="vertical" className="h-6" />
      <h1 className="text-sm font-semibold">ARA - At Risk Authorization</h1>
      <div className="ml-auto flex items-center gap-4">
        <QuickSearch />
        {user && (
          <div className="flex items-center gap-2">
            <span className="text-sm text-muted-foreground">
              {user.displayName}
            </span>
            <Badge variant="secondary">
              {ROLE_LABELS[user.role] ?? "Unknown"}
            </Badge>
          </div>
        )}
      </div>
    </header>
  );
}
