export interface AraDocument {
  araDocumentId: number;
  araId: number;
  fileName: string;
  storagePath: string;
  uploadedByUserId: number | null;
  uploadedAt: string;
}

export interface CreateDocumentRequest {
  fileName: string;
  storagePath: string;
}
