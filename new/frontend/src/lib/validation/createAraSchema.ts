import { z } from "zod";

export const step1Schema = z.object({
  categoryId: z.number().min(1, "Risk category is required"),
  isEarlyStart: z.boolean(),
});

export const step2Schema = z
  .object({
    isEarlyStart: z.boolean(),
    contractNumber: z.string().nullable(),
    omsNumber: z.string().nullable(),
    division: z.string().nullable(),
    deliveryOrderNumber: z.string().nullable(),
    contractType: z.string().nullable(),
    title: z.string().nullable(),
    customerName: z.string().nullable(),
    amountTotal: z.number().min(0.01, "Amount must be greater than zero"),
    amountRequested: z.number().nullable(),
    totalAnticipated: z.number().nullable(),
    percentAnticipated: z.number().nullable(),
    revenueDescriptionId: z.number().nullable(),
    earlyStartReasonId: z.number().nullable(),
    earlyStartReasonOther: z.string().nullable(),
    company: z.string().nullable(),
    isEac: z.string().nullable(),
    startDate: z.string().nullable(),
    expirationDate: z.string().nullable(),
  })
  .refine(
    (data) => {
      if (!data.isEarlyStart) {
        return !!data.contractNumber?.trim();
      }
      return true;
    },
    {
      message: "Contract Number is required for Non-Early Start ARAs",
      path: ["contractNumber"],
    },
  )
  .refine(
    (data) => {
      if (data.isEarlyStart) {
        return !!data.omsNumber?.trim();
      }
      return true;
    },
    {
      message: "OMS Number is required for Early Start ARAs",
      path: ["omsNumber"],
    },
  );

export const step3Schema = z.object({
  programManagerId: z.number().min(1, "Program Manager is required"),
  contractAdministratorId: z
    .number()
    .min(1, "Contract Administrator is required"),
  controllerId: z.number().min(1, "Controller is required"),
  opsVpUserId: z.number().nullable(),
});

export const createAraSchema = z.object({
  categoryId: z.number().min(1),
  programManagerId: z.number().min(1),
  contractAdministratorId: z.number().min(1),
  controllerId: z.number().min(1),
  opsVpUserId: z.number().nullable(),
  division: z.string().nullable(),
  contractNumber: z.string().nullable(),
  deliveryOrderNumber: z.string().nullable(),
  contractType: z.string().nullable(),
  omsNumber: z.string().nullable(),
  title: z.string().nullable(),
  customerName: z.string().nullable(),
  amountTotal: z.number().min(0.01),
  amountRequested: z.number().nullable(),
  totalAnticipated: z.number().nullable(),
  percentAnticipated: z.number().nullable(),
  revenueDescriptionId: z.number().nullable(),
  isEarlyStart: z.boolean(),
  earlyStartReasonId: z.number().nullable(),
  earlyStartReasonOther: z.string().nullable(),
  company: z.string().nullable(),
  isEac: z.string().nullable(),
  startDate: z.string().nullable(),
  expirationDate: z.string().nullable(),
});

export type CreateAraFormData = z.infer<typeof createAraSchema>;
