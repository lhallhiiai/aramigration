export interface ClinEntry {
  clinEntryId: number;
  araId: number;
  clinNumber: string;
  clinDescription: string | null;
  cost: number;
  fee: number;
  total: number;
}

export interface CreateClinRequest {
  clinNumber: string;
  clinDescription: string | null;
  cost: number;
  fee: number;
}

export interface UpdateClinRequest {
  clinEntryId: number;
  clinNumber: string;
  clinDescription: string | null;
  cost: number;
  fee: number;
}
