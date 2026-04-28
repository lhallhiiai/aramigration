import { describe, it, expect } from 'vitest'
import { step1Schema, step2Schema, step3Schema } from './createAraSchema'

describe('step1Schema', () => {
  it('passes with a valid category and early start flag', () => {
    const result = step1Schema.safeParse({ categoryId: 1, isEarlyStart: false })
    expect(result.success).toBe(true)
  })

  it('fails when categoryId is 0', () => {
    const result = step1Schema.safeParse({ categoryId: 0, isEarlyStart: false })
    expect(result.success).toBe(false)
  })

  it('fails when categoryId is missing', () => {
    const result = step1Schema.safeParse({ isEarlyStart: true })
    expect(result.success).toBe(false)
  })
})

describe('step2Schema', () => {
  const validNonEarlyStart = {
    isEarlyStart: false,
    contractNumber: 'W56KGY-19-C-0001',
    omsNumber: null,
    division: 'DIV1',
    deliveryOrderNumber: null,
    contractType: 'CPFF',
    title: null,
    customerName: 'US Army',
    amountTotal: 100000,
    amountRequested: null,
    totalAnticipated: null,
    percentAnticipated: null,
    revenueDescriptionId: 1,
    earlyStartReasonId: null,
    earlyStartReasonOther: null,
    company: 'HII',
    isEac: null,
    startDate: '2026-01-01',
    expirationDate: '2026-12-31',
  }

  it('passes for a valid Non-Early Start ARA', () => {
    const result = step2Schema.safeParse(validNonEarlyStart)
    expect(result.success).toBe(true)
  })

  it('fails when contractNumber is missing for Non-Early Start', () => {
    const result = step2Schema.safeParse({ ...validNonEarlyStart, contractNumber: null })
    expect(result.success).toBe(false)
    if (!result.success) {
      const contractError = result.error.issues.find(
        (issue) => issue.path.includes('contractNumber'),
      )
      expect(contractError).toBeDefined()
    }
  })

  it('fails when amountTotal is zero', () => {
    const result = step2Schema.safeParse({ ...validNonEarlyStart, amountTotal: 0 })
    expect(result.success).toBe(false)
  })

  it('passes for Early Start with omsNumber provided', () => {
    const earlyStart = {
      ...validNonEarlyStart,
      isEarlyStart: true,
      contractNumber: null,
      omsNumber: 'OMS-2026-001',
    }
    const result = step2Schema.safeParse(earlyStart)
    expect(result.success).toBe(true)
  })

  it('fails for Early Start without omsNumber', () => {
    const earlyStart = {
      ...validNonEarlyStart,
      isEarlyStart: true,
      contractNumber: null,
      omsNumber: null,
    }
    const result = step2Schema.safeParse(earlyStart)
    expect(result.success).toBe(false)
  })
})

describe('step3Schema', () => {
  it('passes with all required role IDs', () => {
    const result = step3Schema.safeParse({
      programManagerId: 1,
      contractAdministratorId: 2,
      controllerId: 3,
      opsVpUserId: null,
    })
    expect(result.success).toBe(true)
  })

  it('fails when programManagerId is missing', () => {
    const result = step3Schema.safeParse({
      programManagerId: 0,
      contractAdministratorId: 2,
      controllerId: 3,
      opsVpUserId: null,
    })
    expect(result.success).toBe(false)
  })

  it('allows optional opsVpUserId', () => {
    const result = step3Schema.safeParse({
      programManagerId: 1,
      contractAdministratorId: 2,
      controllerId: 3,
      opsVpUserId: 4,
    })
    expect(result.success).toBe(true)
  })
})
