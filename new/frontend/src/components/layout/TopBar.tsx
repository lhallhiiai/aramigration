import { useOktaAuth } from "@okta/okta-react";
import { ChevronDown, LogOut } from "lucide-react";
import { SidebarTrigger } from "@/components/ui/sidebar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
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
  const { oktaAuth } = useOktaAuth();

  return (
    <header className="flex h-20 w-full shrink-0 items-center gap-4 bg-hii-navy px-6">
      <SidebarTrigger className="-ml-1 text-white/60 hover:bg-hii-navy-700 hover:text-white focus-visible:ring-2 focus-visible:ring-white/50" />

      <div className="border-l border-hii-navy-300/40 pl-5">
        <p className="text-[10px] font-semibold uppercase tracking-[0.2em] text-hii-navy-300">
          At Risk Authorization
        </p>
        <p className="text-lg font-semibold tracking-tight text-white">ARA</p>
        <p className="text-[9px] tracking-[0.15em] text-hii-navy-300/70">
          REVISION 2.0
        </p>
      </div>

      <div className="ml-auto">
        {user && (
          <DropdownMenu>
            <DropdownMenuTrigger className="flex items-center gap-2 rounded px-3 py-2 text-sm text-white/90 hover:bg-hii-navy-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/50">
              <span>{user.displayName}</span>
              <span className="text-hii-navy-300">·</span>
              <span className="text-xs text-hii-navy-300">
                {ROLE_LABELS[user.role] ?? "User"}
              </span>
              <ChevronDown className="size-3 text-hii-navy-300" />
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem
                onClick={() => void oktaAuth.signOut()}
                className="gap-2"
              >
                <LogOut className="size-3.5" />
                Sign out
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        )}
      </div>
    </header>
  );
}
