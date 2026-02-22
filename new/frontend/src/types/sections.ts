export interface AraPmSection {
  araPmSectionId: number;
  araId: number;
  fundsInAdvance: string | null;
  contractDefinization: string | null;
  pertinentInformation: string | null;
  workStarted: string | null;
  consequence: string | null;
  currentStatus: string | null;
  changeInScope: string | null;
  actionToClear: string | null;
  earlyStartNecessary: string | null;
  otherNecessary: string | null;
}

export interface SavePmSectionRequest {
  fundsInAdvance: string | null;
  contractDefinization: string | null;
  pertinentInformation: string | null;
  workStarted: string | null;
  consequence: string | null;
  currentStatus: string | null;
  changeInScope: string | null;
  actionToClear: string | null;
  earlyStartNecessary: string | null;
  otherNecessary: string | null;
}

export interface AraControllerSection {
  araControllerSectionId: number;
  araId: number;
  controllerId: number;
  interestImpact: number | null;
  burnRate: number | null;
  totalCost: number | null;
  totalFee: number | null;
  incurredCost: number | null;
  incurredFee: number | null;
  company: string | null;
}

export interface SaveControllerSectionRequest {
  interestImpact: number | null;
  burnRate: number | null;
  incurredCost: number | null;
  incurredFee: number | null;
  company: string | null;
}
