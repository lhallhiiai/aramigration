import { create } from "zustand";

interface UiState {
  sidebarOpen: boolean;
  toggleSidebar: () => void;
  quickSearchTerm: string;
  setQuickSearchTerm: (term: string) => void;
}

export const useUiStore = create<UiState>((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
  quickSearchTerm: "",
  setQuickSearchTerm: (term: string) => set({ quickSearchTerm: term }),
}));
