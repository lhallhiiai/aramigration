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
import { AraTable } from "@/components/Ara/AraTable";
import { useArchivedAras, useNegateAra } from "@/hooks/useAras";
import { useAuth } from "@/hooks/useAuth";
import { AraStatus } from "@/types/enums";
import type { AraListItem } from "@/types";

export function ArchivedPage() {
  const { data, isLoading, isError, refetch } = useArchivedAras();
  const { isContractAdministrator } = useAuth();
  const [negateTarget, setNegateTarget] = useState<AraListItem | null>(null);
  const negateMutation = useNegateAra(negateTarget?.araId ?? 0);

  function handleNegate() {
    if (!negateTarget) return;
    negateMutation.mutate(undefined, {
      onSuccess: () => {
        setNegateTarget(null);
        refetch();
      },
    });
  }

  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-bold">Archived ARAs</h2>
      <p className="text-sm text-muted-foreground">
        Exported and negated ARAs.
      </p>
      <AraTable
        aras={data}
        isLoading={isLoading}
        isError={isError}
        emptyMessage="No archived ARAs found."
        onRetry={() => refetch()}
        actions={
          isContractAdministrator
            ? (ara) =>
                ara.status === AraStatus.Exported ? (
                  <Button
                    variant="destructive"
                    size="sm"
                    onClick={() => setNegateTarget(ara)}
                  >
                    Negate
                  </Button>
                ) : null
            : undefined
        }
      />
      <AlertDialog
        open={negateTarget !== null}
        onOpenChange={(open) => {
          if (!open) setNegateTarget(null);
        }}
      >
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Negate ARA?</AlertDialogTitle>
            <AlertDialogDescription>
              This will change the status of ARA{" "}
              {negateTarget?.reference ?? `#${negateTarget?.araId}`} from
              Exported to Negated. This action indicates a contract modification
              has been received.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleNegate}
              disabled={negateMutation.isPending}
            >
              {negateMutation.isPending ? "Negating..." : "Negate"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
