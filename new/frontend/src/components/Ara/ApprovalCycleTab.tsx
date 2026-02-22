import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useApprovals } from "@/hooks/useApprovals";
import { useAllUsers } from "@/hooks/useUsers";
import { ApprovalActionType } from "@/types/enums";
import { formatDateTime } from "@/lib/format";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import { EmptyState } from "@/components/shared/EmptyState";

interface ApprovalCycleTabProps {
  araId: number;
}

const ACTION_LABELS: Record<number, string> = {
  [ApprovalActionType.Review]: "Reviewed",
  [ApprovalActionType.Approve]: "Approved",
  [ApprovalActionType.Reject]: "Rejected",
};

function getActionVariant(
  action: number,
): "default" | "secondary" | "destructive" | "outline" {
  switch (action) {
    case ApprovalActionType.Approve:
      return "default";
    case ApprovalActionType.Reject:
      return "destructive";
    default:
      return "secondary";
  }
}

export function ApprovalCycleTab({ araId }: ApprovalCycleTabProps) {
  const { data: records, isLoading, isError, refetch } = useApprovals(araId);
  const { data: users } = useAllUsers();

  function getUserName(userId: number | null): string {
    if (!userId || !users) return "Unknown";
    const user = users.find((u) => u.userId === userId);
    return user?.displayName ?? "Unknown";
  }

  if (isLoading) return <LoadingState rows={3} />;
  if (isError) return <ErrorState onRetry={() => refetch()} />;
  if (!records || records.length === 0)
    return <EmptyState message="No approval actions recorded yet." />;

  const groupedByRevision = records.reduce<
    Record<number, typeof records>
  >((acc, record) => {
    const rev = record.araRevision;
    if (!acc[rev]) acc[rev] = [];
    acc[rev].push(record);
    return acc;
  }, {});

  const revisions = Object.keys(groupedByRevision)
    .map(Number)
    .sort((a, b) => b - a);

  return (
    <div className="space-y-4">
      {revisions.map((rev) => (
        <Card key={rev}>
          <CardHeader>
            <CardTitle className="text-base">Revision {rev}</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {groupedByRevision[rev]
                .sort((a, b) => a.sequenceOrder - b.sequenceOrder)
                .map((record) => (
                  <div
                    key={record.approvalRecordId}
                    className="flex items-start justify-between rounded-md border p-3"
                  >
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className="text-sm font-medium">
                          {getUserName(record.approverId)}
                        </span>
                        <Badge variant={getActionVariant(record.action)}>
                          {ACTION_LABELS[record.action] ?? "Unknown"}
                        </Badge>
                      </div>
                      {record.comment && (
                        <p className="text-sm text-muted-foreground">
                          {record.comment}
                        </p>
                      )}
                      {record.rejectionAreas && (
                        <p className="text-xs text-muted-foreground">
                          Affected areas: {record.rejectionAreas}
                        </p>
                      )}
                    </div>
                    <span className="text-xs text-muted-foreground">
                      {formatDateTime(record.actionTakenAt)}
                    </span>
                  </div>
                ))}
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
