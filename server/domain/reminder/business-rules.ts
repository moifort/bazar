import { match } from 'ts-pattern'
import type { ReminderFrequency } from './types'

const addMonths = (date: Date, months: number): Date => {
  const result = new Date(date)
  const originalDay = result.getDate()
  result.setDate(1)
  result.setMonth(result.getMonth() + months)
  const lastDayOfTargetMonth = new Date(result.getFullYear(), result.getMonth() + 1, 0).getDate()
  result.setDate(Math.min(originalDay, lastDayOfTargetMonth))
  return result
}

const addYears = (date: Date, years: number): Date => {
  return addMonths(date, years * 12)
}

const addDays = (date: Date, days: number): Date => {
  const result = new Date(date)
  result.setDate(result.getDate() + days)
  return result
}

export const computeNextDueDate = (
  current: Date,
  frequency: ReminderFrequency,
  customIntervalDays: number | null,
  now: Date = new Date(),
): Date => {
  const base = current.getTime() >= now.getTime() ? current : now
  return match(frequency)
    .with('monthly', () => addMonths(base, 1))
    .with('quarterly', () => addMonths(base, 3))
    .with('biannual', () => addMonths(base, 6))
    .with('annual', () => addYears(base, 1))
    .with('custom-days', () => {
      if (customIntervalDays == null)
        throw new Error('customIntervalDays is required when frequency is custom-days')
      return addDays(base, customIntervalDays)
    })
    .exhaustive()
}

export const isOneShot = (frequency: ReminderFrequency | null): boolean => frequency === null
