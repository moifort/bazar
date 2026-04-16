import { describe, expect, test } from 'bun:test'
import {
  parseCustomIntervalDays,
  parseDueDate,
  parseReminderFrequency,
  ReminderTitle,
} from './primitives'

describe('ReminderTitle', () => {
  test('accepts a non-empty string', () => {
    expect(ReminderTitle('Changer la pile')).toBe('Changer la pile' as never)
  })

  test('rejects empty string', () => {
    expect(() => ReminderTitle('')).toThrow()
  })

  test('rejects string longer than 200 chars', () => {
    expect(() => ReminderTitle('a'.repeat(201))).toThrow()
  })

  test('accepts 200-char string', () => {
    const title = 'a'.repeat(200)
    expect(ReminderTitle(title)).toBe(title as never)
  })
})

describe('parseReminderFrequency', () => {
  test('accepts known frequencies', () => {
    expect(parseReminderFrequency('monthly')).toBe('monthly')
    expect(parseReminderFrequency('quarterly')).toBe('quarterly')
    expect(parseReminderFrequency('biannual')).toBe('biannual')
    expect(parseReminderFrequency('annual')).toBe('annual')
    expect(parseReminderFrequency('custom-days')).toBe('custom-days')
  })

  test('rejects unknown frequency', () => {
    expect(() => parseReminderFrequency('weekly')).toThrow()
  })
})

describe('parseCustomIntervalDays', () => {
  test('accepts positive integer', () => {
    expect(parseCustomIntervalDays(30)).toBe(30)
  })

  test('accepts numeric string', () => {
    expect(parseCustomIntervalDays('45')).toBe(45)
  })

  test('rejects zero', () => {
    expect(() => parseCustomIntervalDays(0)).toThrow()
  })

  test('rejects negative', () => {
    expect(() => parseCustomIntervalDays(-1)).toThrow()
  })

  test('rejects value above 3650', () => {
    expect(() => parseCustomIntervalDays(3651)).toThrow()
  })

  test('rejects non-integer', () => {
    expect(() => parseCustomIntervalDays(1.5)).toThrow()
  })
})

describe('parseDueDate', () => {
  test('accepts ISO string', () => {
    const d = parseDueDate('2026-06-15T10:00:00.000Z')
    expect(d).toBeInstanceOf(Date)
    expect(d.toISOString()).toBe('2026-06-15T10:00:00.000Z')
  })

  test('accepts Date instance', () => {
    const d = parseDueDate(new Date('2026-06-15'))
    expect(d).toBeInstanceOf(Date)
  })

  test('rejects non-date', () => {
    expect(() => parseDueDate('not a date')).toThrow()
  })
})
