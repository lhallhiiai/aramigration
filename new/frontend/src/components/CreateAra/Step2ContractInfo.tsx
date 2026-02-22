import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import type { CreateAraFormData } from "@/lib/validation/createAraSchema";

interface Step2ContractInfoProps {
  formData: CreateAraFormData;
  onChange: (updates: Partial<CreateAraFormData>) => void;
  errors: Record<string, string | undefined>;
}

export function Step2ContractInfo({
  formData,
  onChange,
  errors,
}: Step2ContractInfoProps) {
  return (
    <div className="space-y-6">
      <div>
        <Label className="text-base font-semibold">
          {formData.isEarlyStart
            ? "Early Start Information"
            : "Contract Information"}
        </Label>
        <p className="mt-1 text-sm text-muted-foreground">
          {formData.isEarlyStart
            ? "Provide the OMS Number and project details."
            : "Provide the JAMIS/Contract Number and contract details."}
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        {!formData.isEarlyStart ? (
          <>
            <div className="space-y-1.5">
              <Label htmlFor="contractNumber">Contract Number *</Label>
              <Input
                id="contractNumber"
                value={formData.contractNumber ?? ""}
                onChange={(e) =>
                  onChange({ contractNumber: e.target.value || null })
                }
              />
              {errors.contractNumber && (
                <p className="text-xs text-destructive">
                  {errors.contractNumber}
                </p>
              )}
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="deliveryOrderNumber">
                Delivery Order Number
              </Label>
              <Input
                id="deliveryOrderNumber"
                value={formData.deliveryOrderNumber ?? ""}
                onChange={(e) =>
                  onChange({ deliveryOrderNumber: e.target.value || null })
                }
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="contractType">Contract Type</Label>
              <Input
                id="contractType"
                value={formData.contractType ?? ""}
                onChange={(e) =>
                  onChange({ contractType: e.target.value || null })
                }
              />
            </div>
          </>
        ) : (
          <>
            <div className="space-y-1.5">
              <Label htmlFor="omsNumber">OMS Number *</Label>
              <Input
                id="omsNumber"
                value={formData.omsNumber ?? ""}
                onChange={(e) =>
                  onChange({ omsNumber: e.target.value || null })
                }
              />
              {errors.omsNumber && (
                <p className="text-xs text-destructive">
                  {errors.omsNumber}
                </p>
              )}
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="customerName">Customer</Label>
              <Input
                id="customerName"
                value={formData.customerName ?? ""}
                onChange={(e) =>
                  onChange({ customerName: e.target.value || null })
                }
              />
            </div>
          </>
        )}

        <div className="space-y-1.5">
          <Label htmlFor="title">Title</Label>
          <Input
            id="title"
            value={formData.title ?? ""}
            onChange={(e) => onChange({ title: e.target.value || null })}
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="division">Division</Label>
          <Input
            id="division"
            value={formData.division ?? ""}
            onChange={(e) => onChange({ division: e.target.value || null })}
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="amountTotal">Amount Total *</Label>
          <Input
            id="amountTotal"
            type="number"
            step="0.01"
            value={formData.amountTotal || ""}
            onChange={(e) =>
              onChange({
                amountTotal: parseFloat(e.target.value) || 0,
              })
            }
          />
          {errors.amountTotal && (
            <p className="text-xs text-destructive">{errors.amountTotal}</p>
          )}
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="amountRequested">Amount Requested</Label>
          <Input
            id="amountRequested"
            type="number"
            step="0.01"
            value={formData.amountRequested ?? ""}
            onChange={(e) =>
              onChange({
                amountRequested: e.target.value
                  ? parseFloat(e.target.value)
                  : null,
              })
            }
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="company">Company</Label>
          <Input
            id="company"
            value={formData.company ?? ""}
            onChange={(e) => onChange({ company: e.target.value || null })}
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="startDate">Start Date</Label>
          <Input
            id="startDate"
            type="date"
            value={formData.startDate ?? ""}
            onChange={(e) =>
              onChange({ startDate: e.target.value || null })
            }
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="expirationDate">Expiration Date</Label>
          <Input
            id="expirationDate"
            type="date"
            value={formData.expirationDate ?? ""}
            onChange={(e) =>
              onChange({ expirationDate: e.target.value || null })
            }
          />
        </div>
      </div>
    </div>
  );
}
