import { describe, expect, test } from 'bun:test'
import { appAccountToken, isActive, planOf } from '~/domain/entitlement/business-rules'
import type { Entitlement } from '~/domain/entitlement/types'
import type { UserId } from '~/domain/shared/types'

const NOW = new Date('2026-07-20T12:00:00.000Z')
const userId = 'user-1' as UserId

const entitlement = (overrides: Partial<Entitlement> = {}): Entitlement =>
  ({
    userId,
    productId: 'co.polyforms.bazar.premium.yearly',
    originalTransactionId: '2000000123456789',
    appAccountToken: appAccountToken(userId),
    expiresAt: new Date('2027-07-20T12:00:00.000Z'),
    updatedAt: NOW,
    ...overrides,
  }) as Entitlement

describe('appAccountToken', () => {
  test('is a stable version-5 UUID for a given user', () => {
    const token = appAccountToken(userId)
    expect(token).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/)
    // Derived, never stored: the same user must get the same token forever, on
    // any instance, after any reinstall.
    expect(appAccountToken(userId)).toBe(token)
  })

  test('gives two users two different tokens', () => {
    expect(appAccountToken('user-2' as UserId)).not.toBe(appAccountToken(userId))
  })

  test('is frozen — this vector must never change', () => {
    // A change of namespace or algorithm silently detaches every subscription
    // already sold from its owner. This vector is the tripwire.
    expect(appAccountToken('dev-user' as UserId) as string).toBe(
      '4b4722a1-3fa9-5f10-aec5-21f21f68cd40',
    )
  })
})

describe('isActive', () => {
  test('a paid period still running is active', () => {
    expect(isActive(entitlement(), NOW)).toBe(true)
  })

  test('a period that has run out is not', () => {
    expect(isActive(entitlement({ expiresAt: new Date('2026-07-19T12:00:00.000Z') }), NOW)).toBe(
      false,
    )
  })

  test('a refund ends it on the spot, whatever the expiry says', () => {
    expect(isActive(entitlement({ revokedAt: NOW }), NOW)).toBe(false)
  })
})

describe('planOf', () => {
  test('no entitlement at all is the free plan', () => {
    expect(planOf(undefined, NOW)).toBe('free')
  })

  test('an active entitlement is premium', () => {
    expect(planOf(entitlement(), NOW)).toBe('premium')
  })

  test('an expired or revoked entitlement falls back to free', () => {
    expect(planOf(entitlement({ expiresAt: new Date('2026-01-01') }), NOW)).toBe('free')
    expect(planOf(entitlement({ revokedAt: NOW }), NOW)).toBe('free')
  })
})
