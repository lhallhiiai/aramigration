import { useState } from "react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
  TableFooter,
} from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Trash2, Plus } from "lucide-react";
import { useClins, useCreateClin, useUpdateClin, useDeleteClin } from "@/hooks/useClins";
import { formatCurrency } from "@/lib/format";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import { EmptyState } from "@/components/shared/EmptyState";
import type { CreateClinRequest } from "@/types";

interface ClinWorksheetProps {
  araId: number;
  isEditable: boolean;
}

export function ClinWorksheet({ araId, isEditable }: ClinWorksheetProps) {
  const { data: clins, isLoading, isError, refetch } = useClins(araId);
  const createMutation = useCreateClin(araId);
  const updateMutation = useUpdateClin(araId);
  const deleteMutation = useDeleteClin(araId);
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [newClin, setNewClin] = useState<CreateClinRequest>({
    clinNumber: "",
    clinDescription: null,
    cost: 0,
    fee: 0,
  });

  function handleAdd() {
    createMutation.mutate(newClin, {
      onSuccess: () => {
        setShowAddDialog(false);
        setNewClin({ clinNumber: "", clinDescription: null, cost: 0, fee: 0 });
      },
    });
  }

  function handleInlineUpdate(
    clinEntryId: number,
    clinNumber: string,
    clinDescription: string | null,
    cost: number,
    fee: number,
  ) {
    updateMutation.mutate({
      clinEntryId,
      request: { clinEntryId, clinNumber, clinDescription, cost, fee },
    });
  }

  if (isLoading) return <LoadingState rows={3} />;
  if (isError) return <ErrorState onRetry={() => refetch()} />;

  const totalCost = clins?.reduce((sum, c) => sum + c.cost, 0) ?? 0;
  const totalFee = clins?.reduce((sum, c) => sum + c.fee, 0) ?? 0;
  const grandTotal = totalCost + totalFee;

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <h4 className="text-sm font-semibold">CLIN Worksheet</h4>
        {isEditable && (
          <Button
            variant="outline"
            size="sm"
            onClick={() => setShowAddDialog(true)}
          >
            <Plus className="mr-1 size-4" />
            Add CLIN
          </Button>
        )}
      </div>

      {!clins || clins.length === 0 ? (
        <EmptyState message="No CLIN entries. Add one to begin." />
      ) : (
        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>CLIN Number</TableHead>
                <TableHead>Description</TableHead>
                <TableHead className="text-right">Cost</TableHead>
                <TableHead className="text-right">Fee</TableHead>
                <TableHead className="text-right">Total</TableHead>
                {isEditable && <TableHead className="w-16" />}
              </TableRow>
            </TableHeader>
            <TableBody>
              {clins.map((clin) => (
                <TableRow key={clin.clinEntryId}>
                  <TableCell className="font-medium">
                    {clin.clinNumber}
                  </TableCell>
                  <TableCell>{clin.clinDescription ?? "-"}</TableCell>
                  <TableCell className="text-right">
                    {isEditable ? (
                      <Input
                        type="number"
                        step="0.01"
                        className="w-28 text-right"
                        defaultValue={clin.cost}
                        onBlur={(e) =>
                          handleInlineUpdate(
                            clin.clinEntryId,
                            clin.clinNumber,
                            clin.clinDescription,
                            parseFloat(e.target.value) || 0,
                            clin.fee,
                          )
                        }
                      />
                    ) : (
                      formatCurrency(clin.cost)
                    )}
                  </TableCell>
                  <TableCell className="text-right">
                    {isEditable ? (
                      <Input
                        type="number"
                        step="0.01"
                        className="w-28 text-right"
                        defaultValue={clin.fee}
                        onBlur={(e) =>
                          handleInlineUpdate(
                            clin.clinEntryId,
                            clin.clinNumber,
                            clin.clinDescription,
                            clin.cost,
                            parseFloat(e.target.value) || 0,
                          )
                        }
                      />
                    ) : (
                      formatCurrency(clin.fee)
                    )}
                  </TableCell>
                  <TableCell className="text-right font-medium">
                    {formatCurrency(clin.total)}
                  </TableCell>
                  {isEditable && (
                    <TableCell>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() =>
                          deleteMutation.mutate(clin.clinEntryId)
                        }
                      >
                        <Trash2 className="size-4 text-destructive" />
                      </Button>
                    </TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
            <TableFooter>
              <TableRow>
                <TableCell colSpan={2} className="font-semibold">
                  Totals
                </TableCell>
                <TableCell className="text-right font-semibold">
                  {formatCurrency(totalCost)}
                </TableCell>
                <TableCell className="text-right font-semibold">
                  {formatCurrency(totalFee)}
                </TableCell>
                <TableCell className="text-right font-semibold">
                  {formatCurrency(grandTotal)}
                </TableCell>
                {isEditable && <TableCell />}
              </TableRow>
            </TableFooter>
          </Table>
        </div>
      )}

      <Dialog open={showAddDialog} onOpenChange={setShowAddDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add CLIN Entry</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-1.5">
              <Label htmlFor="clinNumber">CLIN Number</Label>
              <Input
                id="clinNumber"
                value={newClin.clinNumber}
                onChange={(e) =>
                  setNewClin((prev) => ({
                    ...prev,
                    clinNumber: e.target.value,
                  }))
                }
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="clinDesc">Description</Label>
              <Input
                id="clinDesc"
                value={newClin.clinDescription ?? ""}
                onChange={(e) =>
                  setNewClin((prev) => ({
                    ...prev,
                    clinDescription: e.target.value || null,
                  }))
                }
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <Label htmlFor="clinCost">Cost</Label>
                <Input
                  id="clinCost"
                  type="number"
                  step="0.01"
                  value={newClin.cost}
                  onChange={(e) =>
                    setNewClin((prev) => ({
                      ...prev,
                      cost: parseFloat(e.target.value) || 0,
                    }))
                  }
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="clinFee">Fee</Label>
                <Input
                  id="clinFee"
                  type="number"
                  step="0.01"
                  value={newClin.fee}
                  onChange={(e) =>
                    setNewClin((prev) => ({
                      ...prev,
                      fee: parseFloat(e.target.value) || 0,
                    }))
                  }
                />
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setShowAddDialog(false)}
            >
              Cancel
            </Button>
            <Button
              onClick={handleAdd}
              disabled={
                !newClin.clinNumber.trim() || createMutation.isPending
              }
            >
              {createMutation.isPending ? "Adding..." : "Add"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
