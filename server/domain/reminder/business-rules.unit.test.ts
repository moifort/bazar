import { describe, expect, test } from 'bun:test'
import { isOneShot, nextDueDate } from './business-rules'

const date = (iso: string) => new Date(iso)

describe('nextDueDate', () => {
  const past = date('2020-01-01T10:00:00.000Z')
  const future = date('2100-06-15T10:00:00.000Z')

  test('monthly advances by one month', () => {
    const result = nextDueDate(future, 'monthly', undefined, future)
    expect(result.toISOString()).toBe('2100-07-15T10:00:00.000Z')
  })

  test('quarterly advances by three months', () => {
    const result = nextDueDate(future, 'quarterly', undefined, future)
    expect(result.toISOString()).toBe('2100-09-15T10:00:00.000Z')
  })

  test('biannual advances by six months', () => {
    const result = nextDueDate(future, 'biannual', undefined, future)
    expect(result.toISOString()).toBe('2100-12-15T10:00:00.000Z')
  })

  test('annual advances by one year', () => {
    const result = nextDueDate(future, 'annual', undefined, future)
    expect(result.toISOString()).toBe('2101-06-15T10:00:00.000Z')
  })

  test('custom-days advances by the given number of days', () => {
    const result = nextDueDate(future, 'custom-days', 7, future)
    expect(result.toISOString()).toBe('2100-06-22T10:00:00.000Z')
  })

  test('custom-days with 90 days advances correctly', () => {
    const result = nextDueDate(future, 'custom-days', 90, future)
    expect(result.toISOString()).toBe('2100-09-13T10:00:00.000Z')
  })

  test('throws when custom-days has no interval', () => {
    expect(() => nextDueDate(future, 'custom-days', undefined, future)).toThrow()
  })

  test('end-of-month clamps to last day of target month (Jan 31 → Feb 28 non-leap)', () => {
    const jan31 = date('2023-01-31T10:00:00.000Z')
    const result = nextDueDate(jan31, 'monthly', undefined, jan31)
    expect(result.toISOString()).toBe('2023-02-28T10:00:00.000Z')
  })

  test('end-of-month clamps to last day of target month (Jan 31 → Feb 29 leap)', () => {
    const jan31 = date('2024-01-31T10:00:00.000Z')
    const result = nextDueDate(jan31, 'monthly', undefined, jan31)
    expect(result.toISOString()).toBe('2024-02-29T10:00:00.000Z')
  })

  test('annual on leap day rolls to Feb 28 next year', () => {
    const leapDay = date('2024-02-29T10:00:00.000Z')
    const result = nextDueDate(leapDay, 'annual', undefined, leapDay)
    expect(result.toISOString()).toBe('2025-02-28T10:00:00.000Z')
  })

  test('Dec 31 annual → Dec 31 next year', () => {
    const dec31 = date('2100-12-31T10:00:00.000Z')
    const result = nextDueDate(dec31, 'annual', undefined, dec31)
    expect(result.toISOString()).toBe('2101-12-31T10:00:00.000Z')
  })

  test('uses now when current dueDate is in the past to avoid chaining overdue dates', () => {
    const now = date('2026-04-16T12:00:00.000Z')
    const result = nextDueDate(past, 'monthly', undefined, now)
    expect(result.toISOString()).toBe('2026-05-16T12:00:00.000Z')
  })

  test('keeps current when current dueDate is in the future', () => {
    const now = date('2026-04-16T12:00:00.000Z')
    const result = nextDueDate(future, 'monthly', undefined, now)
    expect(result.toISOString()).toBe('2100-07-15T10:00:00.000Z')
  })
})

describe('isOneShot', () => {
  test('returns true when frequency is null', () => {
    expect(isOneShot(undefined)).toBe(true)
  })

  test('returns false for any recurrent frequency', () => {
    expect(isOneShot('monthly')).toBe(false)
    expect(isOneShot('quarterly')).toBe(false)
    expect(isOneShot('biannual')).toBe(false)
    expect(isOneShot('annual')).toBe(false)
    expect(isOneShot('custom-days')).toBe(false)
  })
})
