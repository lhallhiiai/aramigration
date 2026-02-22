import { useMemo, useRef, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import {
  useControllerSection,
  useSaveControllerSection,
} from "@/hooks/useSections";
import { ClinWorksheet } from "./ClinWorksheet";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import { formatCurrency } from "@/lib/format";
import type { SaveControllerSectionRequest } from "@/types";

interface ControllerSectionTabProps {
  araId: number;
  isEditable: boolean;
  isEarlyStart: boolean;
}

const EMPTY_FORM: SaveControllerSectionRequest = {
  interestImpact: null,
  burnRate: null,
  incurredCost: null,
  incurredFee: null,
  company: null,
};

export function ControllerSectionTab({
  araId,
  isEditable,
  isEarlyStart,
}: ControllerSectionTabProps) {
  const { data: section, isLoading, isError, refetch } =
    useControllerSection(araId);
  const saveMutation = useSaveControllerSection(araId);
  const lastSectionId = useRef<number | undefined>(undefined);
  const [edits, setEdits] = useState<Partial<SaveControllerSectionRequest>>({});

  const baseData = useMemo<SaveControllerSectionRequest>(() => {
    if (!section) return EMPTY_FORM;
    return {
      interestImpact: section.interestImpact,
      burnRate: section.burnRate,
      incurredCost: section.incurredCost,
      incurredFee: section.incurredFee,
      company: section.company,
    };
  }, [section]);

  if (section?.araControllerSectionId !== lastSectionId.current) {
    lastSectionId.current = section?.araControllerSectionId;
    setEdits({});
  }

  const formData: SaveControllerSectionRequest = { ...baseData, ...edits };

  function updateField(updates: Partial<SaveControllerSectionRequest>) {
    setEdits((prev) => ({ ...prev, ...updates }));
  }

  function handleSave() {
    saveMutation.mutate(formData);
  }

  if (isLoading) return <LoadingState rows={4} />;
  if (isError) return <ErrorState onRetry={() => refetch()} />;

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="text-base">Controller Section</CardTitle>
          {isEditable && (
            <Button
              size="sm"
              onClick={handleSave}
              disabled={saveMutation.isPending}
            >
              {saveMutation.isPending ? "Saving..." : "Save"}
            </Button>
          )}
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div className="space-y-1.5">
              <Label htmlFor="interestImpact">Interest Impact</Label>
              {isEditable ? (
                <Input
                  id="interestImpact"
                  type="number"
                  step="0.01"
                  value={formData.interestImpact ?? ""}
                  onChange={(e) =>
                    updateField({
                      interestImpact: e.target.value
                        ? parseFloat(e.target.value)
                        : null,
                    })
                  }
                />
              ) : (
                <p className="min-h-9 rounded-md border bg-muted/50 px-3 py-2 text-sm">
                  {formData.interestImpact ?? "-"}
                </p>
              )}
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="burnRate">Expected Burn Rate</Label>
              {isEditable ? (
                <Input
                  id="burnRate"
                  type="number"
                  step="0.01"
                  value={formData.burnRate ?? ""}
                  onChange={(e) =>
                    updateField({
                      burnRate: e.target.value
                        ? parseFloat(e.target.value)
                        : null,
                    })
                  }
                />
              ) : (
                <p className="min-h-9 rounded-md border bg-muted/50 px-3 py-2 text-sm">
                  {formData.burnRate ?? "-"}
                </p>
              )}
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="incurredCost">Incurred Cost</Label>
              {isEditable ? (
                <Input
                  id="incurredCost"
                  type="number"
                  step="0.01"
                  value={formData.incurredCost ?? ""}
                  onChange={(e) =>
                    updateField({
                      incurredCost: e.target.value
                        ? parseFloat(e.target.value)
                        : null,
                    })
                  }
                />
              ) : (
                <p className="min-h-9 rounded-md border bg-muted/50 px-3 py-2 text-sm">
                  {formData.incurredCost ?? "-"}
                </p>
              )}
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="incurredFee">Incurred Fee</Label>
              {isEditable ? (
                <Input
                  id="incurredFee"
                  type="number"
                  step="0.01"
                  value={formData.incurredFee ?? ""}
                  onChange={(e) =>
                    updateField({
                      incurredFee: e.target.value
                        ? parseFloat(e.target.value)
                        : null,
                    })
                  }
                />
              ) : (
                <p className="min-h-9 rounded-md border bg-muted/50 px-3 py-2 text-sm">
                  {formData.incurredFee ?? "-"}
                </p>
              )}
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="company">Company</Label>
              {isEditable ? (
                <Input
                  id="company"
                  value={formData.company ?? ""}
                  onChange={(e) =>
                    updateField({
                      company: e.target.value || null,
                    })
                  }
                />
              ) : (
                <p className="min-h-9 rounded-md border bg-muted/50 px-3 py-2 text-sm">
                  {formData.company || "-"}
                </p>
              )}
            </div>
            {section && (
              <>
                <div className="space-y-1.5">
                  <Label>Total Cost (from CLINs)</Label>
                  <p className="min-h-9 rounded-md border bg-muted/50 px-3 py-2 text-sm font-medium">
                    {section.totalCost !== null
                      ? formatCurrency(section.totalCost)
                      : "-"}
                  </p>
                </div>
                <div className="space-y-1.5">
                  <Label>Total Fee (from CLINs)</Label>
                  <p className="min-h-9 rounded-md border bg-muted/50 px-3 py-2 text-sm font-medium">
                    {section.totalFee !== null
                      ? formatCurrency(section.totalFee)
                      : "-"}
                  </p>
                </div>
              </>
            )}
          </div>
        </CardContent>
      </Card>

      {!isEarlyStart && (
        <ClinWorksheet araId={araId} isEditable={isEditable} />
      )}
    </div>
  );
}
