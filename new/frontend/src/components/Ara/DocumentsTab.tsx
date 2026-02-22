import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Trash2, FileText, Plus } from "lucide-react";
import { useDocuments, useCreateDocument, useDeleteDocument } from "@/hooks/useDocuments";
import { formatDateTime } from "@/lib/format";
import { LoadingState } from "@/components/shared/LoadingState";
import { ErrorState } from "@/components/shared/ErrorState";
import { EmptyState } from "@/components/shared/EmptyState";

interface DocumentsTabProps {
  araId: number;
  canUpload: boolean;
}

export function DocumentsTab({ araId, canUpload }: DocumentsTabProps) {
  const { data: documents, isLoading, isError, refetch } = useDocuments(araId);
  const createMutation = useCreateDocument(araId);
  const deleteMutation = useDeleteDocument(araId);
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [fileName, setFileName] = useState("");
  const [storagePath, setStoragePath] = useState("");

  function handleAdd() {
    createMutation.mutate(
      { fileName, storagePath },
      {
        onSuccess: () => {
          setShowAddDialog(false);
          setFileName("");
          setStoragePath("");
        },
      },
    );
  }

  if (isLoading) return <LoadingState rows={3} />;
  if (isError) return <ErrorState onRetry={() => refetch()} />;

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle className="text-base">Documents</CardTitle>
        {canUpload && (
          <Button
            variant="outline"
            size="sm"
            onClick={() => setShowAddDialog(true)}
          >
            <Plus className="mr-1 size-4" />
            Add Document
          </Button>
        )}
      </CardHeader>
      <CardContent>
        {!documents || documents.length === 0 ? (
          <EmptyState message="No documents uploaded." />
        ) : (
          <div className="space-y-2">
            {documents.map((doc) => (
              <div
                key={doc.araDocumentId}
                className="flex items-center justify-between rounded-md border p-3"
              >
                <div className="flex items-center gap-3">
                  <FileText className="size-5 text-muted-foreground" />
                  <div>
                    <p className="text-sm font-medium">{doc.fileName}</p>
                    <p className="text-xs text-muted-foreground">
                      Uploaded {formatDateTime(doc.uploadedAt)}
                    </p>
                  </div>
                </div>
                {canUpload && (
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => deleteMutation.mutate(doc.araDocumentId)}
                  >
                    <Trash2 className="size-4 text-destructive" />
                  </Button>
                )}
              </div>
            ))}
          </div>
        )}
      </CardContent>

      <Dialog open={showAddDialog} onOpenChange={setShowAddDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Register Document</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-muted-foreground">
            File upload to Azure Blob Storage is not yet available. Register
            document metadata for now.
          </p>
          <div className="space-y-4">
            <div className="space-y-1.5">
              <Label htmlFor="docName">File Name</Label>
              <Input
                id="docName"
                value={fileName}
                onChange={(e) => setFileName(e.target.value)}
                placeholder="document.pdf"
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="docPath">Storage Path</Label>
              <Input
                id="docPath"
                value={storagePath}
                onChange={(e) => setStoragePath(e.target.value)}
                placeholder="/uploads/document.pdf"
              />
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
                !fileName.trim() ||
                !storagePath.trim() ||
                createMutation.isPending
              }
            >
              {createMutation.isPending ? "Registering..." : "Register"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Card>
  );
}
