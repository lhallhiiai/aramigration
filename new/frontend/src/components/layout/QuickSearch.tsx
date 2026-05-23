import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";

export function QuickSearch() {
  const [value, setValue] = useState("");
  const navigate = useNavigate();

  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Enter" && value.trim().length >= 2) {
      navigate(`/search?q=${encodeURIComponent(value.trim())}`);
      setValue("");
    }
  }

  return (
    <div className="relative w-64">
      <Search className="absolute left-2.5 top-2.5 size-4 text-muted-foreground" />
      <Input
        placeholder="Quick search ARA ID or title…"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={handleKeyDown}
        className="pl-9"
      />
    </div>
  );
}
