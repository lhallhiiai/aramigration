import { useLocation, Link } from "react-router-dom";
import {
  ClipboardList,
  LayoutDashboard,
  PlusCircle,
  Search,
  Archive,
  Info,
} from "lucide-react";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { useAuth } from "@/hooks/useAuth";
import { QuickSearch } from "./QuickSearch";

interface NavItem {
  label: string;
  path: string;
  icon: React.ComponentType<{ className?: string }>;
  creatorOnly?: boolean;
}

const TOP_ITEMS: NavItem[] = [
  { label: "My Action List", path: "/action-list", icon: ClipboardList },
  { label: "Dashboard", path: "/dashboard", icon: LayoutDashboard },
];

const ARA_LIST_ITEMS: NavItem[] = [
  { label: "Create ARA", path: "/create", icon: PlusCircle, creatorOnly: true },
  { label: "Archived", path: "/archived", icon: Archive },
];

const SEARCH_ITEMS: NavItem[] = [
  { label: "Search ARA", path: "/search", icon: Search },
];

const ADMIN_ITEMS: NavItem[] = [
  { label: "System Information", path: "/system-info", icon: Info },
];

interface NavGroupProps {
  items: NavItem[];
  isCreator: boolean;
}

function NavGroup({ items, isCreator }: NavGroupProps) {
  const location = useLocation();
  const visible = items.filter((item) => !item.creatorOnly || isCreator);

  return (
    <>
      {visible.map((item) => {
        const isActive = location.pathname === item.path;
        return (
          <SidebarMenuItem key={item.path} className="relative">
            {isActive && (
              <div className="pointer-events-none absolute left-0 top-0 h-full w-[3px] rounded-r-sm bg-hii-navy" />
            )}
            <SidebarMenuButton
              asChild
              isActive={isActive}
              className={
                isActive
                  ? "pl-4 font-semibold text-hii-navy"
                  : "pl-4 text-text-primary hover:bg-[#F3F4F6]"
              }
            >
              <Link to={item.path}>
                <item.icon className="size-4 shrink-0" />
                <span>{item.label}</span>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        );
      })}
    </>
  );
}

export function AppSidebar() {
  const { isCreator } = useAuth();

  return (
    <Sidebar>
      <SidebarContent className="pt-2">
        <SidebarGroup>
          <SidebarGroupContent>
            <SidebarMenu>
              <NavGroup items={TOP_ITEMS} isCreator={isCreator} />
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarGroup>
          <SidebarGroupLabel className="text-[11px] font-semibold uppercase tracking-[0.12em] text-text-secondary">
            ARA List
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              <NavGroup items={ARA_LIST_ITEMS} isCreator={isCreator} />
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarGroup>
          <SidebarGroupLabel className="text-[11px] font-semibold uppercase tracking-[0.12em] text-text-secondary">
            Search
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              <NavGroup items={SEARCH_ITEMS} isCreator={isCreator} />
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarGroup>
          <SidebarGroupLabel className="text-[11px] font-semibold uppercase tracking-[0.12em] text-text-secondary">
            Administration
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              <NavGroup items={ADMIN_ITEMS} isCreator={isCreator} />
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      <SidebarFooter className="border-t border-border-subtle p-3">
        <QuickSearch />
      </SidebarFooter>
    </Sidebar>
  );
}
