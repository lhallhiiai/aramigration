import { useState } from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import type { RejectRequest } from "@/types";

interface RejectDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onReject: (request: RejectRequest) => void;
  isPending: boolean;
}

export function RejectDialog({
  open,
  onOpenChange,
  onReject,
  isPending,
}: RejectDialogProps) {
  const [comment, setComment] = useState("");
  const [rejectionAreas, setRejectionAreas] = useState("");

  function handleSubmit() {
    onReject({
      comment,
      rejectionReasonId: null,
      rejectionAreas: rejectionAreas || null,
    });
    setComment("");
    setRejectionAreas("");
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Reject ARA</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <div className="space-y-1.5">
            <Label htmlFor="rejectComment">Comment (required)</Label>
            <Textarea
              id="rejectComment"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              maxLength={2000}
              rows={4}
              placeholder="Provide a reason for rejection..."
            />
            <p className="text-xs text-muted-foreground">
              {comment.length}/2000 characters
            </p>
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="rejectionAreas">
              Affected Areas (optional)
            </Label>
            <Input
              id="rejectionAreas"
              value={rejectionAreas}
              onChange={(e) => setRejectionAreas(e.target.value)}
              placeholder="e.g., PM Section, Financial data"
            />
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button
            variant="destructive"
            onClick={handleSubmit}
            disabled={!comment.trim() || isPending}
          >
            {isPending ? "Rejecting..." : "Reject"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
