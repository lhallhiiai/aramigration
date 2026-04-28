import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { RejectDialog } from "./RejectDialog";
import {
  useSubmitByPm,
  useSubmitByCa,
  useSubmitByController,
  useApproveAra,
  useRejectAra,
  useCancelAra,
  useNegateAra,
} from "@/hooks/useAras";
import { AraStatus, UserRole } from "@/types/enums";
import { isTerminalStatus } from "@/lib/ara-helpers";
import type { AraDetail, User, RejectRequest } from "@/types";

interface WorkflowActionBarProps {
  ara: AraDetail;
  currentUser: User;
}

export function WorkflowActionBar({
  ara,
  currentUser,
}: WorkflowActionBarProps) {
  const submitPm = useSubmitByPm(ara.araId);
  const submitCa = useSubmitByCa(ara.araId);
  const submitController = useSubmitByController(ara.araId);
  const approve = useApproveAra(ara.araId);
  const reject = useRejectAra(ara.araId);
  const cancel = useCancelAra(ara.araId);
  const negate = useNegateAra(ara.araId);

  const [showRejectDialog, setShowRejectDialog] = useState(false);
  const [confirmAction, setConfirmAction] = useState<{
    title: string;
    description: string;
    onConfirm: () => void;
    isPending: boolean;
  } | null>(null);

  const isPm = currentUser.userId === ara.programManagerId;
  const isCa = currentUser.userId === ara.contractAdministratorId;
  const isController = currentUser.userId === ara.controllerId;
  const isApprover = currentUser.role === UserRole.Approver;

  const canSubmitPm = isPm && ara.status === AraStatus.Draft;
  const canSubmitCa =
    isCa && ara.status === AraStatus.PendingContractAdministrator;
  const canSubmitController =
    isController && ara.status === AraStatus.PendingController;
  const canApprove =
    isApprover && ara.status === AraStatus.PendingApproval;
  const canReject =
    (isCa && ara.status === AraStatus.PendingContractAdministrator) ||
    (isController && ara.status === AraStatus.PendingController) ||
    (isApprover && ara.status === AraStatus.PendingApproval);
  const canCancel = isPm && !isTerminalStatus(ara.status);
  const canNegate =
    currentUser.role === UserRole.ContractAdministrator &&
    (ara.status === AraStatus.Approved || ara.status === AraStatus.Exported);

  const hasAnyAction =
    canSubmitPm ||
    canSubmitCa ||
    canSubmitController ||
    canApprove ||
    canReject ||
    canCancel ||
    canNegate;

  if (!hasAnyAction) return null;

  function handleReject(request: RejectRequest) {
    reject.mutate(request, {
      onSuccess: () => setShowRejectDialog(false),
    });
  }

  return (
    <>
      <div className="sticky bottom-0 flex items-center gap-2 border-t bg-background p-4">
        {canSubmitPm && (
          <Button
            onClick={() =>
              setConfirmAction({
                title: "Sign & Submit",
                description:
                  "This will submit the ARA to the Contract Administrator for review. Your section will become read-only.",
                onConfirm: () => submitPm.mutate(),
                isPending: submitPm.isPending,
              })
            }
          >
            Sign & Submit
          </Button>
        )}

        {canSubmitCa && (
          <Button
            onClick={() =>
              setConfirmAction({
                title: "Submit for Next Approval",
                description:
                  "This will submit the ARA to the Controller for review.",
                onConfirm: () => submitCa.mutate(),
                isPending: submitCa.isPending,
              })
            }
          >
            Submit for Next Approval
          </Button>
        )}

        {canSubmitController && (
          <Button
            onClick={() =>
              setConfirmAction({
                title: "Submit for Approval",
                description:
                  "This will submit the ARA for final approval.",
                onConfirm: () => submitController.mutate(),
                isPending: submitController.isPending,
              })
            }
          >
            Submit for Approval
          </Button>
        )}

        {canApprove && (
          <Button
            onClick={() =>
              setConfirmAction({
                title: "Approve ARA",
                description: "This will approve the ARA.",
                onConfirm: () => approve.mutate(undefined),
                isPending: approve.isPending,
              })
            }
          >
            Approve
          </Button>
        )}

        {canReject && (
          <Button
            variant="destructive"
            onClick={() => setShowRejectDialog(true)}
          >
            Reject
          </Button>
        )}

        {canCancel && (
          <Button
            variant="outline"
            onClick={() =>
              setConfirmAction({
                title: "Cancel ARA",
                description:
                  "This will cancel the ARA. This action cannot be undone.",
                onConfirm: () => cancel.mutate(),
                isPending: cancel.isPending,
              })
            }
          >
            Cancel ARA
          </Button>
        )}

        {canNegate && (
          <Button
            variant="destructive"
            onClick={() =>
              setConfirmAction({
                title: "Negate ARA",
                description:
                  "This will change the ARA status from Exported to Negated, indicating a contract modification has been received.",
                onConfirm: () => negate.mutate(),
                isPending: negate.isPending,
              })
            }
          >
            Negate
          </Button>
        )}
      </div>

      <RejectDialog
        open={showRejectDialog}
        onOpenChange={setShowRejectDialog}
        onReject={handleReject}
        isPending={reject.isPending}
      />

      <AlertDialog
        open={confirmAction !== null}
        onOpenChange={(open) => {
          if (!open) setConfirmAction(null);
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>{confirmAction?.title}</AlertDialogTitle>
            <AlertDialogDescription>
              {confirmAction?.description}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                confirmAction?.onConfirm();
                setConfirmAction(null);
              }}
              disabled={confirmAction?.isPending}
            >
              {confirmAction?.isPending ? "Processing..." : "Confirm"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
