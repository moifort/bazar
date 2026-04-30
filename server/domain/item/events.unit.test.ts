import { describe, expect, test } from 'bun:test'
import { detectThresholdCrossing } from './events'
import type { LowStockThreshold, Quantity } from './types'

const q = (n: number) => n as Quantity
const t = (n: number) => n as LowStockThreshold

describe('detectThresholdCrossing', () => {
  test('detects when quantity drops from above to at threshold', () => {
    expect(
      detectThresholdCrossing(
        { quantity: q(3), lowStockThreshold: t(2) },
        { quantity: q(2), lowStockThreshold: t(2) },
      ),
    ).toBe(true)
  })

  test('detects when quantity drops from above to below threshold', () => {
    expect(
      detectThresholdCrossing(
        { quantity: q(5), lowStockThreshold: t(2) },
        { quantity: q(1), lowStockThreshold: t(2) },
      ),
    ).toBe(true)
  })

  test('does not fire when quantity stays above threshold', () => {
    expect(
      detectThresholdCrossing(
        { quantity: q(5), lowStockThreshold: t(2) },
        { quantity: q(3), lowStockThreshold: t(2) },
      ),
    ).toBe(false)
  })

  test('does not fire when quantity was already at or below threshold', () => {
    expect(
      detectThresholdCrossing(
        { quantity: q(2), lowStockThreshold: t(2) },
        { quantity: q(1), lowStockThreshold: t(2) },
      ),
    ).toBe(false)
  })

  test('does not fire when threshold is null', () => {
    expect(
      detectThresholdCrossing(
        { quantity: q(5), lowStockThreshold: null },
        { quantity: q(1), lowStockThreshold: null },
      ),
    ).toBe(false)
  })

  test('does not fire when quantity rises', () => {
    expect(
      detectThresholdCrossing(
        { quantity: q(1), lowStockThreshold: t(2) },
        { quantity: q(5), lowStockThreshold: t(2) },
      ),
    ).toBe(false)
  })

  test('fires when threshold is added and quantity is already below', () => {
    expect(
      detectThresholdCrossing(
        { quantity: q(2), lowStockThreshold: null },
        { quantity: q(2), lowStockThreshold: t(3) },
      ),
    ).toBe(true)
  })
})
