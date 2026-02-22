import { differenceInDays, parseISO } from "date-fns";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { AraStatusBadge } from "@/components/Ara/AraStatusBadge";
import { useExpirationAras, useArasByStatus } from "@/hooks/useAras";
import { AraStatus } from "@/types/enums";
import { formatCurrency, formatDate } from "@/lib/format";
import { getRiskCategoryLabel } from "@/lib/ara-helpers";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import { EmptyState } from "@/components/shared/EmptyState";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useNavigate } from "react-router-dom";

function ExpirationSection() {
  const { data: aras, isLoading, isError, refetch } = useExpirationAras();
  const navigate = useNavigate();

  if (isLoading) return <LoadingState rows={5} />;
  if (isError) return <ErrorState onRetry={() => refetch()} />;
  if (!aras || aras.length === 0)
    return <EmptyState message="No upcoming ARA expirations." />;

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Reference</TableHead>
            <TableHead>Title</TableHead>
            <TableHead>Category</TableHead>
            <TableHead className="text-right">Amount</TableHead>
            <TableHead>Expiration</TableHead>
            <TableHead>Days Left</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {aras.map((ara) => {
            const daysLeft = ara.expirationDate
              ? differenceInDays(parseISO(ara.expirationDate), new Date())
              : null;

            return (
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
                <TableCell className="text-right">
                  {formatCurrency(ara.amountTotal)}
                </TableCell>
                <TableCell>{formatDate(ara.expirationDate)}</TableCell>
                <TableCell>
                  {daysLeft !== null && (
                    <span
                      className={
                        daysLeft <= 30
                          ? "font-semibold text-destructive"
                          : "text-muted-foreground"
                      }
                    >
                      {daysLeft} days
                    </span>
                  )}
                </TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
    </div>
  );
}

interface StatusCardProps {
  status: AraStatus;
  label: string;
}

function StatusCard({ status, label }: StatusCardProps) {
  const { data: aras, isLoading } = useArasByStatus(status);

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-sm font-medium">{label}</CardTitle>
        <AraStatusBadge status={status} />
      </CardHeader>
      <CardContent>
        <div className="text-3xl font-bold">
          {isLoading ? "-" : (aras?.length ?? 0)}
        </div>
        <p className="text-xs text-muted-foreground">
          {isLoading ? "Loading..." : "ARAs in this stage"}
        </p>
      </CardContent>
    </Card>
  );
}

export function DashboardPage() {
  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold">Dashboard</h2>

      <div>
        <h3 className="mb-3 text-lg font-semibold">Pending ARAs by Status</h3>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <StatusCard status={AraStatus.Draft} label="Draft" />
          <StatusCard
            status={AraStatus.PendingContractAdministrator}
            label="Pending CA"
          />
          <StatusCard
            status={AraStatus.PendingController}
            label="Pending Controller"
          />
          <StatusCard
            status={AraStatus.PendingApproval}
            label="Pending Approval"
          />
        </div>
      </div>

      <div>
        <h3 className="mb-3 text-lg font-semibold">
          Critical ARA Expirations
        </h3>
        <ExpirationSection />
      </div>
    </div>
  );
}
