import { useMemo } from "react";
import { differenceInDays, parseISO } from "date-fns";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { Card, CardContent } from "@/components/ui/card";
import { SectionHeading } from "@/components/shared/SectionHeading";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import { EmptyState } from "@/components/shared/EmptyState";
import { useExpirationAras, useArasByStatus } from "@/hooks/useAras";
import { AraStatus } from "@/types/enums";
import type { AraListItem } from "@/types/ara";

const HII_NAVY = "#14323B";

function formatAmount(value: number): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(value);
}

function formatAxisAmount(value: number): string {
  if (value >= 1_000_000) return `$${(value / 1_000_000).toFixed(0)}M`;
  if (value >= 1_000) return `$${(value / 1_000).toFixed(0)}K`;
  return `$${value}`;
}

interface ChartTooltipProps {
  active?: boolean;
  payload?: Array<{ value?: number }>;
  label?: string;
}

function AmountTooltip({ active, payload, label }: ChartTooltipProps) {
  if (!active || !payload?.length) return null;
  return (
    <div className="rounded border border-border-subtle bg-white px-3 py-2 shadow-sm">
      <p className="mb-1 text-xs text-text-secondary">{label}</p>
      <p className="text-sm font-semibold text-hii-navy">
        {formatAmount(payload[0].value ?? 0)}
      </p>
    </div>
  );
}

interface StatusRow {
  label: string;
  status: AraStatus;
  count: number;
  amount: number;
}

function sumAmounts(items: AraListItem[] | undefined): number {
  return items?.reduce((acc, a) => acc + a.amountTotal, 0) ?? 0;
}

function PendingActionPanel() {
  const pm = useArasByStatus(AraStatus.Draft);
  const contracts = useArasByStatus(AraStatus.PendingContractAdministrator);
  const controller = useArasByStatus(AraStatus.PendingController);
  const approvalChain = useArasByStatus(AraStatus.PendingApproval);
  // Rejected maps to Cancelled (9) — the current status used for permanently closed ARAs.
  // TODO: introduce a dedicated Rejected status if the domain distinguishes rejection from cancellation.
  const rejected = useArasByStatus(AraStatus.Cancelled);
  const approved = useArasByStatus(AraStatus.Approved);

  const isLoading =
    pm.isLoading || contracts.isLoading || controller.isLoading ||
    approvalChain.isLoading || rejected.isLoading || approved.isLoading;
  const isError =
    pm.isError || contracts.isError || controller.isError ||
    approvalChain.isError || rejected.isError || approved.isError;

  const rows = useMemo<StatusRow[]>(
    () => [
      { label: "PM",             status: AraStatus.Draft,                        count: pm.data?.length ?? 0,           amount: sumAmounts(pm.data) },
      { label: "Contracts",      status: AraStatus.PendingContractAdministrator, count: contracts.data?.length ?? 0,    amount: sumAmounts(contracts.data) },
      { label: "Controller",     status: AraStatus.PendingController,            count: controller.data?.length ?? 0,   amount: sumAmounts(controller.data) },
      { label: "Approval Chain", status: AraStatus.PendingApproval,              count: approvalChain.data?.length ?? 0,amount: sumAmounts(approvalChain.data) },
      { label: "Rejected",       status: AraStatus.Cancelled,                    count: rejected.data?.length ?? 0,     amount: sumAmounts(rejected.data) },
      { label: "Approved",       status: AraStatus.Approved,                     count: approved.data?.length ?? 0,     amount: sumAmounts(approved.data) },
    ],
    [pm.data, contracts.data, controller.data, approvalChain.data, rejected.data, approved.data],
  );

  const totalCount = rows.reduce((s, r) => s + r.count, 0);
  const totalAmount = rows.reduce((s, r) => s + r.amount, 0);

  const handleRetry = () => {
    void pm.refetch();
    void contracts.refetch();
    void controller.refetch();
    void approvalChain.refetch();
    void rejected.refetch();
    void approved.refetch();
  };

  return (
    <Card className="shadow-[0_1px_2px_rgba(0,0,0,0.04),_0_1px_3px_rgba(0,0,0,0.06)]">
      <CardContent className="p-5">
        <SectionHeading>Pending Action</SectionHeading>
        <h2 className="mb-4 mt-1 text-lg font-semibold text-text-primary">
          Open ARAs by Stage
        </h2>

        {isLoading && <LoadingState rows={4} />}
        {isError && <ErrorState onRetry={handleRetry} />}

        {!isLoading && !isError && (
          <>
            <div className="mb-5">
              {totalAmount === 0 ? (
                <EmptyState message="No pending ARA amounts to chart." />
              ) : (
                <ResponsiveContainer width="100%" height={260}>
                  <BarChart
                    data={rows}
                    margin={{ top: 4, right: 4, left: 4, bottom: 4 }}
                    aria-label="Bar chart showing sum of ARA amounts by workflow state"
                  >
                    <CartesianGrid
                      strokeDasharray="0"
                      stroke="#EEF0F2"
                      vertical={false}
                    />
                    <XAxis
                      dataKey="label"
                      tick={{ fontSize: 11, fill: "#6B7280" }}
                      tickLine={false}
                      axisLine={false}
                      interval={0}
                      width={60}
                    />
                    <YAxis
                      tickFormatter={formatAxisAmount}
                      tick={{ fontSize: 11, fill: "#6B7280" }}
                      tickLine={false}
                      axisLine={false}
                      width={56}
                    />
                    <Tooltip content={<AmountTooltip />} cursor={{ fill: "#F5F6F7" }} />
                    <Bar
                      dataKey="amount"
                      fill={HII_NAVY}
                      radius={[2, 2, 0, 0]}
                      maxBarSize={48}
                    />
                  </BarChart>
                </ResponsiveContainer>
              )}
            </div>

            <div className="mb-4 border-t border-border-subtle" />

            <div className="max-h-[480px] overflow-y-auto">
              <table className="w-full text-sm" role="table">
                <thead className="sticky top-0 z-10 bg-white">
                  <tr className="border-b border-border-subtle">
                    <th className="pb-2 text-left text-[11px] font-semibold uppercase tracking-wider text-text-secondary">
                      State
                    </th>
                    <th className="pb-2 text-right text-[11px] font-semibold uppercase tracking-wider text-text-secondary">
                      Count
                    </th>
                    <th className="pb-2 text-right text-[11px] font-semibold uppercase tracking-wider text-text-secondary">
                      Sum of Amounts
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {rows.map((row) => (
                    <tr
                      key={row.status}
                      className="border-b border-border-hairline"
                    >
                      <td className="py-3 text-text-primary">{row.label}</td>
                      <td className="py-3 text-right tabular-nums text-text-primary">
                        {/* TODO: make Count a link to /action-list?status=<value> once the filter param is wired */}
                        {row.count}
                      </td>
                      <td className="py-3 text-right tabular-nums text-text-primary">
                        {formatAmount(row.amount)}
                      </td>
                    </tr>
                  ))}
                </tbody>
                <tfoot>
                  <tr className="border-t border-text-primary">
                    <td className="pt-3 font-semibold text-text-primary">
                      Totals
                    </td>
                    <td className="pt-3 text-right font-semibold tabular-nums text-text-primary">
                      {totalCount}
                    </td>
                    <td className="pt-3 text-right font-semibold tabular-nums text-text-primary">
                      {formatAmount(totalAmount)}
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </>
        )}
      </CardContent>
    </Card>
  );
}

interface ExpirationBucket {
  label: string;
  minDays: number;
  maxDays: number;
  count: number;
  amount: number;
}

const EXPIRATION_BUCKETS: ReadonlyArray<Omit<ExpirationBucket, "count" | "amount">> = [
  { label: "Expired",    minDays: -Infinity, maxDays: -1  },
  { label: "≤ 5 days",  minDays: 0,         maxDays: 5   },
  { label: "6–10 days", minDays: 6,         maxDays: 10  },
  { label: "11–15 days",minDays: 11,        maxDays: 15  },
  { label: "16–30 days",minDays: 16,        maxDays: 30  },
];

interface ExpirationTooltipProps {
  active?: boolean;
  payload?: Array<{ value?: number; payload?: ExpirationBucket }>;
  label?: string;
}

function ExpirationTooltip({ active, payload }: ExpirationTooltipProps) {
  if (!active || !payload?.length) return null;
  const bucket = payload[0].payload;
  if (!bucket) return null;
  return (
    <div className="rounded border border-border-subtle bg-white px-3 py-2 shadow-sm">
      <p className="mb-1 text-xs font-semibold text-text-primary">{bucket.label}</p>
      <p className="text-xs text-text-secondary">
        {bucket.count} ARA{bucket.count !== 1 ? "s" : ""}
      </p>
      <p className="text-sm font-semibold text-hii-navy">
        {formatAmount(bucket.amount)}
      </p>
    </div>
  );
}

function ExpirationPanel() {
  const { data: aras, isLoading, isError, refetch } = useExpirationAras();

  const buckets = useMemo<ExpirationBucket[]>(() => {
    const result = EXPIRATION_BUCKETS.map((b) => ({ ...b, count: 0, amount: 0 }));
    for (const ara of aras ?? []) {
      if (!ara.expirationDate) continue;
      const days = differenceInDays(parseISO(ara.expirationDate), new Date());
      const bucket = result.find((b) => days >= b.minDays && days <= b.maxDays);
      if (bucket) {
        bucket.count += 1;
        bucket.amount += ara.amountTotal;
      }
    }
    return result;
  }, [aras]);

  const hasData = buckets.some((b) => b.count > 0);
  const totalCount = buckets.reduce((s, b) => s + b.count, 0);
  const totalAmount = buckets.reduce((s, b) => s + b.amount, 0);

  return (
    <Card className="shadow-[0_1px_2px_rgba(0,0,0,0.04),_0_1px_3px_rgba(0,0,0,0.06)]">
      <CardContent className="p-5">
        <SectionHeading>Critical ARA Expirations</SectionHeading>
        <h2 className="mb-4 mt-1 text-lg font-semibold text-text-primary">
          Expiration Distribution
        </h2>

        {isLoading && <LoadingState rows={5} />}
        {isError && <ErrorState onRetry={() => void refetch()} />}

        {!isLoading && !isError && (!aras || aras.length === 0) && (
          <EmptyState message="No upcoming ARA expirations." />
        )}

        {!isLoading && !isError && aras && aras.length > 0 && (
          <>
            <div className="mb-5">
              {!hasData ? (
                <EmptyState message="No expiration data to chart." />
              ) : (
                <ResponsiveContainer width="100%" height={260}>
                  <BarChart
                    data={buckets}
                    margin={{ top: 4, right: 16, left: 4, bottom: 4 }}
                    aria-label="Bar chart showing total ARA amounts grouped by days until expiration"
                  >
                    <CartesianGrid
                      strokeDasharray="0"
                      stroke="#EEF0F2"
                      vertical={false}
                    />
                    <XAxis
                      dataKey="label"
                      tick={{ fontSize: 10, fill: "#6B7280" }}
                      tickLine={false}
                      axisLine={false}
                      interval={0}
                    />
                    <YAxis
                      tickFormatter={formatAxisAmount}
                      tick={{ fontSize: 11, fill: "#6B7280" }}
                      tickLine={false}
                      axisLine={false}
                      width={56}
                    />
                    <Tooltip
                      content={<ExpirationTooltip />}
                      cursor={{ fill: "#F5F6F7" }}
                    />
                    <Bar
                      dataKey="amount"
                      fill={HII_NAVY}
                      radius={[2, 2, 0, 0]}
                      maxBarSize={48}
                    />
                  </BarChart>
                </ResponsiveContainer>
              )}
            </div>

            <div className="mb-4 border-t border-border-subtle" />

            <div className="max-h-[480px] overflow-y-auto">
              <table className="w-full table-fixed text-sm" role="table">
                <caption className="sr-only">
                  ARA expiration counts and amounts grouped by days until expiration
                </caption>
                <colgroup>
                  <col style={{ width: "55%" }} />
                  <col style={{ width: "15%" }} />
                  <col style={{ width: "30%" }} />
                </colgroup>
                <thead className="sticky top-0 z-10 bg-white">
                  <tr className="border-b border-border-subtle">
                    <th scope="col" className="px-4 pb-3 text-left text-[11px] font-semibold uppercase tracking-wider text-text-secondary">
                      Expires in…
                    </th>
                    <th scope="col" className="px-4 pb-3 text-right text-[11px] font-semibold uppercase tracking-wider text-text-secondary">
                      Count
                    </th>
                    <th scope="col" className="px-4 pb-3 text-right text-[11px] font-semibold uppercase tracking-wider text-text-secondary">
                      Sum of Amounts
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {buckets.map((bucket) => (
                    <tr key={bucket.label} className="border-b border-border-hairline">
                      <td className="px-4 py-3 text-text-primary">{bucket.label}</td>
                      <td className="px-4 py-3 text-right tabular-nums text-text-primary">
                        {/* TODO: link to ARA LIST filtered by expiration bucket when filter route is wired */}
                        {bucket.count}
                      </td>
                      <td className="px-4 py-3 text-right tabular-nums text-text-primary">
                        {formatAmount(bucket.amount)}
                      </td>
                    </tr>
                  ))}
                </tbody>
                <tfoot>
                  <tr className="border-t border-[#111]">
                    <td className="px-4 pt-3 font-medium text-text-primary">Totals</td>
                    <td className="px-4 pt-3 text-right font-medium tabular-nums text-text-primary">
                      {totalCount}
                    </td>
                    <td className="px-4 pt-3 text-right font-medium tabular-nums text-text-primary">
                      {formatAmount(totalAmount)}
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </>
        )}
      </CardContent>
    </Card>
  );
}

export function DashboardPage() {
  return (
    <div className="space-y-2">
      <p className="text-[11px] font-semibold uppercase tracking-[0.15em] text-text-secondary">
        Dashboard
      </p>
      <h1 className="mb-6 border-b border-border-subtle pb-4 text-2xl font-semibold text-text-primary">
        All Open ARAs
      </h1>

      <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
        <PendingActionPanel />
        <ExpirationPanel />
      </div>
    </div>
  );
}
