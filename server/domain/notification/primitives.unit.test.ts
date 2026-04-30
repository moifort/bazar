import { describe, expect, test } from 'bun:test'
import { NotificationToken, parseNotificationPlatform } from './primitives'

describe('NotificationToken', () => {
  test('accepts a non-empty string', () => {
    expect(NotificationToken('abc123')).toBe('abc123' as never)
  })

  test('rejects empty string', () => {
    expect(() => NotificationToken('')).toThrow()
  })

  test('rejects strings longer than 4096 chars', () => {
    expect(() => NotificationToken('a'.repeat(4097))).toThrow()
  })
})

describe('parseNotificationPlatform', () => {
  test('accepts "ios"', () => {
    expect(parseNotificationPlatform('ios')).toBe('ios')
  })

  test('rejects unknown platforms', () => {
    expect(() => parseNotificationPlatform('android')).toThrow()
    expect(() => parseNotificationPlatform('web')).toThrow()
  })
})
