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
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarHeader,
} from "@/components/ui/sidebar";
import { useAuth } from "@/hooks/useAuth";

interface NavItem {
  label: string;
  path: string;
  icon: React.ComponentType<{ className?: string }>;
  creatorOnly?: boolean;
}

const NAV_ITEMS: NavItem[] = [
  { label: "My Action List", path: "/action-list", icon: ClipboardList },
  { label: "Dashboard", path: "/dashboard", icon: LayoutDashboard },
  { label: "Create ARA", path: "/create", icon: PlusCircle, creatorOnly: true },
  { label: "Search", path: "/search", icon: Search },
  { label: "Archived", path: "/archived", icon: Archive },
  { label: "System Information", path: "/system-info", icon: Info },
];

export function AppSidebar() {
  const location = useLocation();
  const { isCreator } = useAuth();

  const visibleItems = NAV_ITEMS.filter(
    (item) => !item.creatorOnly || isCreator,
  );

  return (
    <Sidebar>
      <SidebarHeader className="border-b px-6 py-4">
        <Link to="/" className="text-lg font-bold tracking-tight">
          ARA
        </Link>
        <p className="text-xs text-muted-foreground">At Risk Authorization</p>
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Navigation</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {visibleItems.map((item) => (
                <SidebarMenuItem key={item.path}>
                  <SidebarMenuButton
                    asChild
                    isActive={location.pathname === item.path}
                  >
                    <Link to={item.path}>
                      <item.icon className="size-4" />
                      <span>{item.label}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
    </Sidebar>
  );
}
