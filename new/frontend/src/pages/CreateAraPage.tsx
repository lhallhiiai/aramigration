import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { StepIndicator } from "@/components/CreateAra/StepIndicator";
import { Step1RiskCategory } from "@/components/CreateAra/Step1RiskCategory";
import { Step2ContractInfo } from "@/components/CreateAra/Step2ContractInfo";
import { Step3RoleAssignment } from "@/components/CreateAra/Step3RoleAssignment";
import { Step4Summary } from "@/components/CreateAra/Step4Summary";
import { useAuth } from "@/hooks/useAuth";
import { useCreateAra } from "@/hooks/useAras";
import {
  step1Schema,
  step2Schema,
  step3Schema,
} from "@/lib/validation/createAraSchema";
import type { CreateAraFormData } from "@/lib/validation/createAraSchema";
import type { ZodError } from "zod";

const STEPS = ["Risk Category", "Contract Info", "Personnel", "Review"];

const INITIAL_FORM_DATA: CreateAraFormData = {
  categoryId: 0,
  programManagerId: 0,
  contractAdministratorId: 0,
  controllerId: 0,
  opsVpUserId: null,
  division: null,
  contractNumber: null,
  deliveryOrderNumber: null,
  contractType: null,
  omsNumber: null,
  title: null,
  customerName: null,
  amountTotal: 0,
  amountRequested: null,
  totalAnticipated: null,
  percentAnticipated: null,
  revenueDescriptionId: null,
  isEarlyStart: false,
  earlyStartReasonId: null,
  earlyStartReasonOther: null,
  company: null,
  isEac: null,
  startDate: null,
  expirationDate: null,
};

function zodErrorsToRecord(error: ZodError): Record<string, string> {
  const result: Record<string, string> = {};
  for (const issue of error.issues) {
    const key = issue.path.join(".");
    if (!result[key]) {
      result[key] = issue.message;
    }
  }
  return result;
}

export function CreateAraPage() {
  const navigate = useNavigate();
  const { isCreator, user } = useAuth();
  const createMutation = useCreateAra();
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState<CreateAraFormData>({
    ...INITIAL_FORM_DATA,
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  if (!isCreator) {
    return (
      <div className="flex flex-col items-center justify-center gap-4 py-20">
        <h2 className="text-2xl font-bold">Access Denied</h2>
        <p className="text-muted-foreground">
          Only users with the Creator role can create ARAs.
        </p>
        <Button variant="outline" onClick={() => navigate("/action-list")}>
          Return to Action List
        </Button>
      </div>
    );
  }

  function updateFormData(updates: Partial<CreateAraFormData>) {
    setFormData((prev) => ({ ...prev, ...updates }));
    setErrors({});
  }

  function validateStep(): boolean {
    try {
      if (step === 1) {
        step1Schema.parse(formData);
      } else if (step === 2) {
        step2Schema.parse(formData);
      } else if (step === 3) {
        step3Schema.parse(formData);
      }
      setErrors({});
      return true;
    } catch (err) {
      const zodErr = err as ZodError;
      setErrors(zodErrorsToRecord(zodErr));
      return false;
    }
  }

  function handleNext() {
    if (validateStep()) {
      setStep((s) => s + 1);
    }
  }

  function handleBack() {
    setStep((s) => s - 1);
    setErrors({});
  }

  function handleCreate() {
    createMutation.mutate(formData, {
      onSuccess: (araId) => {
        navigate(`/aras/${araId}`);
      },
    });
  }

  return (
    <div className="mx-auto max-w-4xl space-y-6">
      <h2 className="text-2xl font-bold">Create ARA</h2>
      <StepIndicator currentStep={step} steps={STEPS} />

      <Card>
        <CardContent className="p-6">
          {step === 1 && (
            <Step1RiskCategory
              selectedCategoryId={formData.categoryId}
              onSelect={(categoryId, isEarlyStart) =>
                updateFormData({ categoryId, isEarlyStart })
              }
            />
          )}
          {step === 2 && (
            <Step2ContractInfo
              formData={formData}
              onChange={updateFormData}
              errors={errors}
            />
          )}
          {step === 3 && (
            <Step3RoleAssignment
              programManagerId={
                formData.programManagerId || (user?.userId ?? 0)
              }
              contractAdministratorId={formData.contractAdministratorId}
              controllerId={formData.controllerId}
              opsVpUserId={formData.opsVpUserId}
              onChange={updateFormData}
              errors={errors}
            />
          )}
          {step === 4 && <Step4Summary formData={formData} />}
        </CardContent>
      </Card>

      <div className="flex justify-between">
        <Button
          variant="outline"
          onClick={handleBack}
          disabled={step === 1}
        >
          Back
        </Button>
        <div className="flex gap-2">
          {step < 4 ? (
            <Button onClick={handleNext}>Next</Button>
          ) : (
            <Button
              onClick={handleCreate}
              disabled={createMutation.isPending}
            >
              {createMutation.isPending ? "Creating..." : "Create ARA"}
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}
