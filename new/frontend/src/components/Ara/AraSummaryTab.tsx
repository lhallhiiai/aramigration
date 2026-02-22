import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatCurrency, formatDate } from "@/lib/format";
import { getRiskCategoryLabel } from "@/lib/ara-helpers";
import { useAllUsers } from "@/hooks/useUsers";
import type { AraDetail } from "@/types";

interface AraSummaryTabProps {
  ara: AraDetail;
}

function InfoRow({ label, value }: { label: string; value: string | null | undefined }) {
  return (
    <div className="flex justify-between py-1.5">
      <span className="text-sm text-muted-foreground">{label}</span>
      <span className="text-sm font-medium">{value || "-"}</span>
    </div>
  );
}

export function AraSummaryTab({ ara }: AraSummaryTabProps) {
  const { data: users } = useAllUsers();

  function getUserName(userId: number | null): string {
    if (!userId || !users) return "-";
    const user = users.find((u) => u.userId === userId);
    return user?.displayName ?? "-";
  }

  return (
    <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Contract Information</CardTitle>
        </CardHeader>
        <CardContent className="space-y-0 divide-y">
          <InfoRow
            label="Risk Category"
            value={getRiskCategoryLabel(ara.riskCategory)}
          />
          <InfoRow
            label="Type"
            value={ara.isEarlyStart ? "Early Start" : "Non-Early Start"}
          />
          {!ara.isEarlyStart && (
            <>
              <InfoRow label="Contract Number" value={ara.contractNumber} />
              <InfoRow
                label="Delivery Order Number"
                value={ara.deliveryOrderNumber}
              />
              <InfoRow label="Contract Type" value={ara.contractType} />
            </>
          )}
          {ara.isEarlyStart && (
            <>
              <InfoRow label="OMS Number" value={ara.omsNumber} />
              <InfoRow label="Customer" value={ara.customerName} />
            </>
          )}
          <InfoRow label="Division" value={ara.division} />
          <InfoRow label="Company" value={ara.company} />
          <InfoRow label="JAMIS ID" value={ara.jamisId} />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Financial Information</CardTitle>
        </CardHeader>
        <CardContent className="space-y-0 divide-y">
          <InfoRow
            label="Amount Total"
            value={formatCurrency(ara.amountTotal)}
          />
          <InfoRow
            label="Amount Requested"
            value={
              ara.amountRequested !== null
                ? formatCurrency(ara.amountRequested)
                : null
            }
          />
          <InfoRow
            label="Total Anticipated"
            value={
              ara.totalAnticipated !== null
                ? formatCurrency(ara.totalAnticipated)
                : null
            }
          />
          <InfoRow
            label="Percent Anticipated"
            value={
              ara.percentAnticipated !== null
                ? `${ara.percentAnticipated}%`
                : null
            }
          />
          <InfoRow label="EAC" value={ara.isEac} />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Personnel</CardTitle>
        </CardHeader>
        <CardContent className="space-y-0 divide-y">
          <InfoRow
            label="Program Manager"
            value={getUserName(ara.programManagerId)}
          />
          <InfoRow
            label="Contract Administrator"
            value={getUserName(ara.contractAdministratorId)}
          />
          <InfoRow label="Controller" value={getUserName(ara.controllerId)} />
          <InfoRow label="Ops VP" value={getUserName(ara.opsVpUserId)} />
          <InfoRow
            label="Created By"
            value={getUserName(ara.createdByUserId)}
          />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Dates</CardTitle>
        </CardHeader>
        <CardContent className="space-y-0 divide-y">
          <InfoRow label="Start Date" value={formatDate(ara.startDate)} />
          <InfoRow
            label="Expiration Date"
            value={formatDate(ara.expirationDate)}
          />
          <InfoRow label="Created" value={formatDate(ara.createdAt)} />
          <InfoRow label="Last Updated" value={formatDate(ara.updatedAt)} />
          <InfoRow label="Exported" value={formatDate(ara.exportedAt)} />
          <InfoRow label="Negated" value={formatDate(ara.negatedAt)} />
          <InfoRow label="Cancelled" value={formatDate(ara.cancelledAt)} />
        </CardContent>
      </Card>

      {ara.isEarlyStart && (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Early Start Details</CardTitle>
          </CardHeader>
          <CardContent className="space-y-0 divide-y">
            <InfoRow
              label="Early Start Reason"
              value={
                ara.earlyStartReasonId
                  ? `Reason #${ara.earlyStartReasonId}`
                  : null
              }
            />
            <InfoRow
              label="Other Reason"
              value={ara.earlyStartReasonOther}
            />
          </CardContent>
        </Card>
      )}
    </div>
  );
}
