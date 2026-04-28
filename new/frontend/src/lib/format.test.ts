import { describe, it, expect } from 'vitest'
import { formatCurrency, formatDate, formatDateTime } from './format'

describe('formatCurrency', () => {
  it('formats a positive amount as USD', () => {
    expect(formatCurrency(1234.56)).toBe('$1,234.56')
  })

  it('formats zero', () => {
    expect(formatCurrency(0)).toBe('$0.00')
  })

  it('formats large amounts with commas', () => {
    expect(formatCurrency(500000)).toBe('$500,000.00')
  })

  it('rounds to two decimal places', () => {
    expect(formatCurrency(99.999)).toBe('$100.00')
  })
})

describe('formatDate', () => {
  it('formats an ISO string to MM/dd/yyyy', () => {
    expect(formatDate('2026-04-27')).toBe('04/27/2026')
  })

  it('returns empty string for null', () => {
    expect(formatDate(null)).toBe('')
  })

  it('returns empty string for undefined', () => {
    expect(formatDate(undefined)).toBe('')
  })
})

describe('formatDateTime', () => {
  it('formats an ISO string to MM/dd/yyyy h:mm a', () => {
    const result = formatDateTime('2026-04-27T14:30:00.000Z')
    // The exact time depends on the test runner's timezone, so check format pattern
    expect(result).toMatch(/04\/27\/2026 \d{1,2}:\d{2} (AM|PM)/)
  })

  it('returns empty string for null', () => {
    expect(formatDateTime(null)).toBe('')
  })
})
