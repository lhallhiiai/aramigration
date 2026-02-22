import { useParams, useNavigate } from "react-router-dom";
import { ArrowLeft } from "lucide-react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Button } from "@/components/ui/button";
import { AraDetailHeader } from "@/components/Ara/AraDetailHeader";
import { AraSummaryTab } from "@/components/Ara/AraSummaryTab";
import { PmSectionTab } from "@/components/Ara/PmSectionTab";
import { ControllerSectionTab } from "@/components/Ara/ControllerSectionTab";
import { DocumentsTab } from "@/components/Ara/DocumentsTab";
import { ApprovalCycleTab } from "@/components/Ara/ApprovalCycleTab";
import { WorkflowActionBar } from "@/components/Ara/WorkflowActionBar";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import { useAraDetail } from "@/hooks/useAras";
import { useAuth } from "@/hooks/useAuth";
import { AraStatus } from "@/types/enums";

export function AraDetailPage() {
  const { araId: araIdParam } = useParams();
  const navigate = useNavigate();
  const araId = Number(araIdParam);
  const { data: ara, isLoading, isError, refetch } = useAraDetail(araId);
  const { user } = useAuth();

  if (isLoading) {
    return (
      <div className="space-y-4">
        <LoadingState rows={8} />
      </div>
    );
  }

  if (isError || !ara) {
    return <ErrorState message="ARA not found." onRetry={() => refetch()} />;
  }

  const isPm = user?.userId === ara.programManagerId;
  const isCa = user?.userId === ara.contractAdministratorId;
  const isController = user?.userId === ara.controllerId;

  const isPmEditable = isPm && ara.status === AraStatus.Draft;
  const isControllerEditable =
    isController && ara.status === AraStatus.PendingController;

  const canUploadDocs =
    (isCa && ara.status === AraStatus.PendingContractAdministrator) ||
    (isController && ara.status === AraStatus.PendingController) ||
    (isPm && ara.status === AraStatus.Draft);

  return (
    <div className="flex flex-col gap-4">
      <div>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => navigate(-1)}
          className="mb-2"
        >
          <ArrowLeft className="mr-1 size-4" />
          Back
        </Button>
        <AraDetailHeader ara={ara} />
      </div>

      <Tabs defaultValue="summary" className="flex-1">
        <TabsList>
          <TabsTrigger value="summary">Summary</TabsTrigger>
          <TabsTrigger value="pm-section">PM Section</TabsTrigger>
          <TabsTrigger value="controller-section">
            Controller Section
          </TabsTrigger>
          <TabsTrigger value="documents">Documents</TabsTrigger>
          <TabsTrigger value="approval-cycle">Approval Cycle</TabsTrigger>
        </TabsList>

        <TabsContent value="summary" className="mt-4">
          <AraSummaryTab ara={ara} />
        </TabsContent>

        <TabsContent value="pm-section" className="mt-4">
          <PmSectionTab araId={araId} isEditable={isPmEditable} />
        </TabsContent>

        <TabsContent value="controller-section" className="mt-4">
          <ControllerSectionTab
            araId={araId}
            isEditable={isControllerEditable}
            isEarlyStart={ara.isEarlyStart}
          />
        </TabsContent>

        <TabsContent value="documents" className="mt-4">
          <DocumentsTab araId={araId} canUpload={canUploadDocs} />
        </TabsContent>

        <TabsContent value="approval-cycle" className="mt-4">
          <ApprovalCycleTab araId={araId} />
        </TabsContent>
      </Tabs>

      {user && <WorkflowActionBar ara={ara} currentUser={user} />}
    </div>
  );
}
