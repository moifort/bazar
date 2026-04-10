import { describe, expect, test } from 'bun:test'
import { fuzzyScore, normalize, searchEntries } from './business-rules'
import type { SearchEntry } from './types'

describe('normalize', () => {
  test('removes accents and lowercases', () => {
    expect(normalize('Étagère Métallique')).toBe('etagere metallique')
  })

  test('trims and collapses whitespace', () => {
    expect(normalize('  hello   world  ')).toBe('hello world')
  })
})

describe('fuzzyScore', () => {
  test('exact match scores 100', () => {
    expect(fuzzyScore('tournevis', 'tournevis')).toBe(100)
  })

  test('prefix match scores 80', () => {
    expect(fuzzyScore('tournevis', 'tournevis cruciforme')).toBe(80)
  })

  test('word prefix scores 60', () => {
    expect(fuzzyScore('cruci', 'tournevis cruciforme')).toBe(60)
  })

  test('substring match scores 40', () => {
    expect(fuzzyScore('nevis', 'tournevis')).toBe(40)
  })

  test('no match scores 0', () => {
    expect(fuzzyScore('xyz', 'tournevis')).toBe(0)
  })
})

describe('searchEntries', () => {
  const entries: SearchEntry[] = [
    { type: 'item', entityId: '1', text: 'Tournevis cruciforme' },
    { type: 'item', entityId: '2', text: 'Perceuse visseuse' },
    { type: 'place', entityId: '3', text: 'Cave' },
    { type: 'room', entityId: '4', text: 'Cuisine' },
  ]

  test('returns matching entries sorted by score', () => {
    const results = searchEntries(entries, 'vis', 10)
    expect(results.length).toBe(2)
    expect(results[0].entityId).toBe('2')
  })

  test('respects limit', () => {
    const results = searchEntries(entries, 'c', 1)
    expect(results.length).toBe(1)
  })

  test('returns empty for empty query', () => {
    expect(searchEntries(entries, '', 10)).toEqual([])
  })
})
