import { describe, expect, test } from 'bun:test'
import { LowStockThreshold } from './primitives'

describe('LowStockThreshold', () => {
  test('accepts a positive integer', () => {
    expect(LowStockThreshold(2)).toBe(2 as never)
  })

  test('accepts numeric string', () => {
    expect(LowStockThreshold('5')).toBe(5 as never)
  })

  test('rejects zero', () => {
    expect(() => LowStockThreshold(0)).toThrow()
  })

  test('rejects negative integers', () => {
    expect(() => LowStockThreshold(-1)).toThrow()
  })

  test('rejects floats', () => {
    expect(() => LowStockThreshold(2.5)).toThrow()
  })

  test('rejects non-numeric values', () => {
    expect(() => LowStockThreshold('abc')).toThrow()
  })
})
