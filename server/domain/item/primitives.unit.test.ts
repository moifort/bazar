import { describe, expect, test } from 'bun:test'
import { ItemTag, LowStockThreshold, parseItemTags } from './primitives'

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

describe('ItemTag', () => {
  test('trims the keyword', () => {
    expect(ItemTag('  cumin  ')).toBe('cumin' as never)
  })

  test('rejects a blank keyword', () => {
    expect(() => ItemTag('   ')).toThrow()
  })

  test('accepts a whole printed line, not just a word', () => {
    expect(ItemTag('Confiture de fraises extra bio 370 g')).toBe(
      'Confiture de fraises extra bio 370 g' as never,
    )
  })

  test('rejects a keyword past 200 characters', () => {
    expect(() => ItemTag('a'.repeat(201))).toThrow()
  })
})

describe('parseItemTags', () => {
  test('keeps the order the keywords were given in', () => {
    expect(parseItemTags(['cumin', 'paprika', 'condiment'])).toEqual([
      'cumin',
      'paprika',
      'condiment',
    ] as never)
  })

  test('treats a different case or accent as the same keyword, first spelling wins', () => {
    expect(parseItemTags(['Épice', 'epice', 'ÉPICE'])).toEqual(['Épice'] as never)
  })

  test('drops the blanks an untouched input field sends', () => {
    expect(parseItemTags(['cumin', '  ', ''])).toEqual(['cumin'] as never)
  })

  test('never caps the list — every readable label goes in', () => {
    const many = Array.from({ length: 60 }, (_, i) => `tag-${i}`)

    expect(parseItemTags(many)).toHaveLength(60)
  })

  test('rejects anything that is not a list of strings', () => {
    expect(() => parseItemTags('cumin')).toThrow()
    expect(() => parseItemTags([42])).toThrow()
  })
})
