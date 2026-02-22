import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useCategories } from "@/hooks/useCategories";
import { useAllUsers } from "@/hooks/useUsers";
import { formatCurrency } from "@/lib/format";
import type { CreateAraFormData } from "@/lib/validation/createAraSchema";

interface Step4SummaryProps {
  formData: CreateAraFormData;
}

function InfoRow({
  label,
  value,
}: {
  label: string;
  value: string | null | undefined;
}) {
  return (
    <div className="flex justify-between py-1.5">
      <span className="text-sm text-muted-foreground">{label}</span>
      <span className="text-sm font-medium">{value || "-"}</span>
    </div>
  );
}

export function Step4Summary({ formData }: Step4SummaryProps) {
  const { data: categories } = useCategories();
  const { data: users } = useAllUsers();

  const category = categories?.find(
    (c) => c.categoryId === formData.categoryId,
  );

  function getUserName(userId: number | null): string {
    if (!userId || !users) return "-";
    const user = users.find((u) => u.userId === userId);
    return user?.displayName ?? "-";
  }

  return (
    <div className="space-y-4">
      <div>
        <p className="text-base font-semibold">Review & Create</p>
        <p className="mt-1 text-sm text-muted-foreground">
          Review all information before creating the ARA.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Category & Type</CardTitle>
          </CardHeader>
          <CardContent className="divide-y">
            <InfoRow
              label="Risk Category"
              value={category?.categoryName}
            />
            <InfoRow
              label="Type"
              value={
                formData.isEarlyStart
                  ? "Early Start"
                  : "Non-Early Start"
              }
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Contract Details</CardTitle>
          </CardHeader>
          <CardContent className="divide-y">
            {!formData.isEarlyStart ? (
              <>
                <InfoRow
                  label="Contract Number"
                  value={formData.contractNumber}
                />
                <InfoRow
                  label="Delivery Order"
                  value={formData.deliveryOrderNumber}
                />
                <InfoRow
                  label="Contract Type"
                  value={formData.contractType}
                />
              </>
            ) : (
              <>
                <InfoRow label="OMS Number" value={formData.omsNumber} />
                <InfoRow label="Customer" value={formData.customerName} />
              </>
            )}
            <InfoRow label="Title" value={formData.title} />
            <InfoRow label="Division" value={formData.division} />
            <InfoRow label="Company" value={formData.company} />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Financial</CardTitle>
          </CardHeader>
          <CardContent className="divide-y">
            <InfoRow
              label="Amount Total"
              value={formatCurrency(formData.amountTotal)}
            />
            <InfoRow
              label="Amount Requested"
              value={
                formData.amountRequested !== null
                  ? formatCurrency(formData.amountRequested)
                  : null
              }
            />
            <InfoRow
              label="Start Date"
              value={formData.startDate}
            />
            <InfoRow
              label="Expiration Date"
              value={formData.expirationDate}
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Personnel</CardTitle>
          </CardHeader>
          <CardContent className="divide-y">
            <InfoRow
              label="Program Manager"
              value={getUserName(formData.programManagerId)}
            />
            <InfoRow
              label="Contract Administrator"
              value={getUserName(formData.contractAdministratorId)}
            />
            <InfoRow
              label="Controller"
              value={getUserName(formData.controllerId)}
            />
            <InfoRow
              label="Ops VP"
              value={getUserName(formData.opsVpUserId)}
            />
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
