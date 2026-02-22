import { Routes, Route, Navigate } from "react-router-dom";
import { TooltipProvider } from "@/components/ui/tooltip";
import { Toaster } from "@/components/ui/sonner";
import { AppLayout } from "@/components/layout/AppLayout";
import { ActionListPage } from "@/pages/ActionListPage";
import { DashboardPage } from "@/pages/DashboardPage";
import { CreateAraPage } from "@/pages/CreateAraPage";
import { SearchPage } from "@/pages/SearchPage";
import { AraDetailPage } from "@/pages/AraDetailPage";
import { ArchivedPage } from "@/pages/ArchivedPage";
import { SystemInfoPage } from "@/pages/SystemInfoPage";
import { NotFoundPage } from "@/pages/NotFoundPage";

export default function App() {
  return (
    <TooltipProvider>
      <Routes>
        <Route element={<AppLayout />}>
          <Route index element={<Navigate to="/action-list" replace />} />
          <Route path="/action-list" element={<ActionListPage />} />
          <Route path="/dashboard" element={<DashboardPage />} />
          <Route path="/create" element={<CreateAraPage />} />
          <Route path="/search" element={<SearchPage />} />
          <Route path="/aras/:araId" element={<AraDetailPage />} />
          <Route path="/archived" element={<ArchivedPage />} />
          <Route path="/system-info" element={<SystemInfoPage />} />
          <Route path="*" element={<NotFoundPage />} />
        </Route>
      </Routes>
      <Toaster position="top-right" richColors />
    </TooltipProvider>
  );
}
