import { describe, it, expect } from 'vitest'
import {
  getStatusLabel,
  getRiskCategoryLabel,
  isTerminalStatus,
  getStatusVariant,
} from './ara-helpers'
import { AraStatus, RiskCategory } from '@/types/enums'

describe('getStatusLabel', () => {
  it('returns the correct label for Draft', () => {
    expect(getStatusLabel(AraStatus.Draft)).toBe('Draft')
  })

  it('returns the correct label for PendingApproval', () => {
    expect(getStatusLabel(AraStatus.PendingApproval)).toBe('Pending Approval')
  })

  it('returns Unknown for an unmapped status value', () => {
    const unmappedStatus = 999 as AraStatus
    expect(getStatusLabel(unmappedStatus)).toBe('Unknown (999)')
  })
})

describe('getRiskCategoryLabel', () => {
  it('returns the correct label for AwardFees', () => {
    expect(getRiskCategoryLabel(RiskCategory.AwardFees)).toBe('Award Fees')
  })

  it('returns the correct label for PreContractCosts', () => {
    expect(getRiskCategoryLabel(RiskCategory.PreContractCosts)).toBe('Pre-Contract Costs')
  })

  it('returns Unknown for an unmapped category value', () => {
    const unmappedCategory = 999 as RiskCategory
    expect(getRiskCategoryLabel(unmappedCategory)).toBe('Unknown (999)')
  })
})

describe('isTerminalStatus', () => {
  it('returns true for Approved', () => {
    expect(isTerminalStatus(AraStatus.Approved)).toBe(true)
  })

  it('returns true for Expired', () => {
    expect(isTerminalStatus(AraStatus.Expired)).toBe(true)
  })

  it('returns true for Negated', () => {
    expect(isTerminalStatus(AraStatus.Negated)).toBe(true)
  })

  it('returns true for Cancelled', () => {
    expect(isTerminalStatus(AraStatus.Cancelled)).toBe(true)
  })

  it('returns false for Draft', () => {
    expect(isTerminalStatus(AraStatus.Draft)).toBe(false)
  })

  it('returns false for PendingApproval', () => {
    expect(isTerminalStatus(AraStatus.PendingApproval)).toBe(false)
  })
})

describe('getStatusVariant', () => {
  it('returns secondary for Draft', () => {
    expect(getStatusVariant(AraStatus.Draft)).toBe('secondary')
  })

  it('returns default for pending statuses', () => {
    expect(getStatusVariant(AraStatus.PendingContractAdministrator)).toBe('default')
    expect(getStatusVariant(AraStatus.PendingController)).toBe('default')
    expect(getStatusVariant(AraStatus.PendingApproval)).toBe('default')
  })

  it('returns outline for Approved', () => {
    expect(getStatusVariant(AraStatus.Approved)).toBe('outline')
  })

  it('returns destructive for terminal negative statuses', () => {
    expect(getStatusVariant(AraStatus.Expired)).toBe('destructive')
    expect(getStatusVariant(AraStatus.Negated)).toBe('destructive')
    expect(getStatusVariant(AraStatus.Cancelled)).toBe('destructive')
  })
})
