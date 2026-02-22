import { useMemo, useRef, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { usePmSection, useSavePmSection } from "@/hooks/useSections";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import type { SavePmSectionRequest } from "@/types";

interface PmSectionTabProps {
  araId: number;
  isEditable: boolean;
}

const FIELDS: { key: keyof SavePmSectionRequest; label: string }[] = [
  { key: "fundsInAdvance", label: "Funds in Advance" },
  { key: "contractDefinization", label: "Contract Definitization" },
  { key: "pertinentInformation", label: "Pertinent Information" },
  { key: "workStarted", label: "Has Work Started?" },
  { key: "consequence", label: "Consequence of Not Authorizing" },
  { key: "currentStatus", label: "Current Status" },
  { key: "changeInScope", label: "Change in Scope" },
  { key: "actionToClear", label: "Action to Clear" },
  { key: "earlyStartNecessary", label: "Early Start Necessary" },
  { key: "otherNecessary", label: "Other" },
];

const EMPTY_FORM: SavePmSectionRequest = {
  fundsInAdvance: null,
  contractDefinization: null,
  pertinentInformation: null,
  workStarted: null,
  consequence: null,
  currentStatus: null,
  changeInScope: null,
  actionToClear: null,
  earlyStartNecessary: null,
  otherNecessary: null,
};

function sectionToFormData(
  section: ReturnType<typeof usePmSection>["data"],
): SavePmSectionRequest {
  if (!section) return EMPTY_FORM;
  return {
    fundsInAdvance: section.fundsInAdvance,
    contractDefinization: section.contractDefinization,
    pertinentInformation: section.pertinentInformation,
    workStarted: section.workStarted,
    consequence: section.consequence,
    currentStatus: section.currentStatus,
    changeInScope: section.changeInScope,
    actionToClear: section.actionToClear,
    earlyStartNecessary: section.earlyStartNecessary,
    otherNecessary: section.otherNecessary,
  };
}

export function PmSectionTab({ araId, isEditable }: PmSectionTabProps) {
  const { data: section, isLoading, isError, refetch } = usePmSection(araId);
  const saveMutation = useSavePmSection(araId);
  const lastSectionId = useRef<number | undefined>(undefined);
  const [edits, setEdits] = useState<Partial<SavePmSectionRequest>>({});

  const baseData = useMemo(() => sectionToFormData(section), [section]);

  if (section?.araPmSectionId !== lastSectionId.current) {
    lastSectionId.current = section?.araPmSectionId;
    setEdits({});
  }

  const formData: SavePmSectionRequest = { ...baseData, ...edits };

  function handleChange(key: keyof SavePmSectionRequest, value: string) {
    setEdits((prev) => ({ ...prev, [key]: value || null }));
  }

  function handleSave() {
    saveMutation.mutate(formData);
  }

  if (isLoading) return <LoadingState rows={5} />;
  if (isError) return <ErrorState onRetry={() => refetch()} />;

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-base">PM Section</CardTitle>
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
      <CardContent className="space-y-4">
        {FIELDS.map(({ key, label }) => (
          <div key={key} className="space-y-1.5">
            <Label htmlFor={key}>{label}</Label>
            {isEditable ? (
              <Textarea
                id={key}
                value={formData[key] ?? ""}
                onChange={(e) => handleChange(key, e.target.value)}
                rows={3}
              />
            ) : (
              <p className="min-h-9 rounded-md border bg-muted/50 px-3 py-2 text-sm">
                {formData[key] || "-"}
              </p>
            )}
          </div>
        ))}
      </CardContent>
    </Card>
  );
}
