import { describe, expect, test } from 'bun:test'
import { normalizeText } from './text'

describe('normalizeText', () => {
  test('removes accents and lowercases', () => {
    expect(normalizeText('Étagère Métallique')).toBe('etagere metallique')
  })

  test('trims and collapses whitespace', () => {
    expect(normalizeText('  hello   world  ')).toBe('hello world')
  })
})
