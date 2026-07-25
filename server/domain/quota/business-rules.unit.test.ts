import { describe, expect, test } from 'bun:test'
import {
  consumed,
  exhausted,
  FREE_MONTHLY_SCANS,
  freshQuota,
  monthlyLimitOf,
  monthOf,
  PREMIUM_YEARLY_SCANS,
  remaining,
  renewsOn,
  windowEndingAt,
} from '~/domain/quota/business-rules'
import { QuotaMonth } from '~/domain/quota/primitives'
import type { Quota } from '~/domain/quota/types'
import { Count } from '~/domain/shared/primitives'
import type { UserId } from '~/domain/shared/types'

const userId = 'user-1' as UserId
const july = QuotaMonth('2026-07')

const spent = (scans: number, month = july): Quota => ({
  ...freshQuota(userId, month),
  scans: Count(scans),
})

describe('monthOf', () => {
  test('reads the month in UTC, not in the caller timezone', () => {
    // 23:30 on 31 July in Paris is still July in UTC — the window must not move
    // with whoever is asking.
    expect(monthOf(new Date('2026-07-31T21:30:00.000Z'))).toBe(july)
    expect(monthOf(new Date('2026-01-01T00:00:00.000Z'))).toBe(QuotaMonth('2026-01'))
  })
})

describe('renewsOn', () => {
  test('is midnight UTC on the 1st of the next month', () => {
    expect(renewsOn(july).toISOString()).toBe('2026-08-01T00:00:00.000Z')
  })

  test('rolls December over into the next year', () => {
    expect(renewsOn(QuotaMonth('2026-12')).toISOString()).toBe('2027-01-01T00:00:00.000Z')
  })
})

describe('windowEndingAt', () => {
  test('lists twelve months, newest first', () => {
    const window = windowEndingAt(july)
    expect(window).toHaveLength(12)
    expect(window[0]).toBe(july)
    expect(window[11]).toBe(QuotaMonth('2025-08'))
  })
})

describe('monthlyLimitOf', () => {
  test('the free plan gets a monthly allowance', () => {
    expect(monthlyLimitOf('free')).toBe(FREE_MONTHLY_SCANS)
  })

  test('premium has none — absence is what the app shows as no counter', () => {
    expect(monthlyLimitOf('premium')).toBeUndefined()
  })
})

describe('remaining', () => {
  test('counts down from the free allowance', () => {
    expect(remaining('free', spent(3))).toBe(Count(FREE_MONTHLY_SCANS - 3))
  })

  test('never goes negative', () => {
    expect(remaining('free', spent(FREE_MONTHLY_SCANS + 5))).toBe(Count(0))
  })

  test('is absent on premium', () => {
    expect(remaining('premium', spent(999))).toBeUndefined()
  })
})

describe('exhausted', () => {
  test('a free user is stopped by this month alone', () => {
    expect(exhausted('free', [spent(FREE_MONTHLY_SCANS - 1)])).toBe(false)
    expect(exhausted('free', [spent(FREE_MONTHLY_SCANS)])).toBe(true)
  })

  test('a premium user is not stopped by a month, however busy', () => {
    expect(exhausted('premium', [spent(500)])).toBe(false)
  })

  test('a premium user is stopped by the twelve-month ceiling', () => {
    // The ceiling is the sum over the window, not any single month: no month
    // reaches it, together they do.
    const window = Array.from({ length: 12 }, () => spent(PREMIUM_YEARLY_SCANS / 12))
    expect(exhausted('premium', window)).toBe(true)
  })

  test('an empty window is nobody being stopped', () => {
    expect(exhausted('free', [])).toBe(false)
    expect(exhausted('premium', [])).toBe(false)
  })
})

describe('consumed', () => {
  test('spends exactly one scan', () => {
    expect(consumed(spent(2)).scans).toBe(Count(3))
  })

  test('leaves the month and the owner alone', () => {
    const next = consumed(spent(0))
    expect(next.month).toBe(july)
    expect(next.userId).toBe(userId)
  })
})
