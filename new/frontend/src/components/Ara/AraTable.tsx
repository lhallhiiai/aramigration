import { useNavigate } from "react-router-dom";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { AraStatusBadge } from "./AraStatusBadge";
import { getRiskCategoryLabel } from "@/lib/ara-helpers";
import { formatCurrency, formatDate } from "@/lib/format";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import { EmptyState } from "@/components/shared/EmptyState";
import type { AraListItem } from "@/types";

interface AraTableProps {
  aras: AraListItem[] | undefined;
  isLoading: boolean;
  isError: boolean;
  emptyMessage?: string;
  onRetry?: () => void;
  actions?: (ara: AraListItem) => React.ReactNode;
}

export function AraTable({
  aras,
  isLoading,
  isError,
  emptyMessage = "No ARAs found.",
  onRetry,
  actions,
}: AraTableProps) {
  const navigate = useNavigate();

  if (isLoading) return <LoadingState rows={8} />;
  if (isError) return <ErrorState onRetry={onRetry} />;
  if (!aras || aras.length === 0) return <EmptyState message={emptyMessage} />;

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-28">Reference</TableHead>
            <TableHead>Title</TableHead>
            <TableHead>Risk Category</TableHead>
            <TableHead>Status</TableHead>
            <TableHead className="text-right">Amount</TableHead>
            <TableHead>Expiration</TableHead>
            <TableHead>Created</TableHead>
            {actions && <TableHead className="w-24">Actions</TableHead>}
          </TableRow>
        </TableHeader>
        <TableBody>
          {aras.map((ara) => (
            <TableRow
              key={ara.araId}
              className="cursor-pointer"
              onClick={() => navigate(`/aras/${ara.araId}`)}
            >
              <TableCell className="font-medium">
                {ara.reference ?? `#${ara.araId}`}
              </TableCell>
              <TableCell className="max-w-48 truncate">
                {ara.title ?? "-"}
              </TableCell>
              <TableCell className="text-sm">
                {getRiskCategoryLabel(ara.riskCategory)}
              </TableCell>
              <TableCell>
                <AraStatusBadge status={ara.status} />
              </TableCell>
              <TableCell className="text-right">
                {formatCurrency(ara.amountTotal)}
              </TableCell>
              <TableCell>{formatDate(ara.expirationDate)}</TableCell>
              <TableCell>{formatDate(ara.createdAt)}</TableCell>
              {actions && (
                <TableCell onClick={(e) => e.stopPropagation()}>
                  {actions(ara)}
                </TableCell>
              )}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
