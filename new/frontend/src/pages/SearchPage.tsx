import { useState, useEffect } from "react";
import { useSearchParams } from "react-router-dom";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { AraTable } from "@/components/Ara/AraTable";
import { useAraSearch } from "@/hooks/useAras";
import { SEARCH_DEBOUNCE_MS } from "@/lib/constants";

export function SearchPage() {
  const [searchParams] = useSearchParams();
  const initialQuery = searchParams.get("q") ?? "";
  const [inputValue, setInputValue] = useState(initialQuery);
  const [debouncedQuery, setDebouncedQuery] = useState(initialQuery);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedQuery(inputValue.trim());
    }, SEARCH_DEBOUNCE_MS);
    return () => clearTimeout(timer);
  }, [inputValue]);

  const { data, isLoading, isError, refetch } = useAraSearch(debouncedQuery);

  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-bold">Search ARA</h2>
      <div className="relative max-w-md">
        <Search className="absolute left-2.5 top-2.5 size-4 text-muted-foreground" />
        <Input
          placeholder="Search by ARA ID, JAMIS ID, or title..."
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          className="pl-9"
          autoFocus
        />
      </div>
      {debouncedQuery.length < 2 ? (
        <p className="py-8 text-center text-sm text-muted-foreground">
          Enter at least 2 characters to search.
        </p>
      ) : (
        <AraTable
          aras={data}
          isLoading={isLoading}
          isError={isError}
          emptyMessage={`No results found for "${debouncedQuery}".`}
          onRetry={() => refetch()}
        />
      )}
    </div>
  );
}
