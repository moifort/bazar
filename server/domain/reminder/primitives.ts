import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  ReminderCompletionId as ReminderCompletionIdType,
  ReminderFrequency,
  ReminderId as ReminderIdType,
  ReminderTitle as ReminderTitleType,
} from '~/domain/reminder/types'

export const ReminderId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<ReminderIdType>()(v)
}

export const ReminderCompletionId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<ReminderCompletionIdType>()(v)
}

export const ReminderTitle = (value: unknown) => {
  const v = z.string().min(1).max(200).parse(value)
  return make<ReminderTitleType>()(v)
}

const reminderFrequencies: ReminderFrequency[] = [
  'monthly',
  'quarterly',
  'biannual',
  'annual',
  'custom-days',
]

export const parseReminderFrequency = (value: unknown): ReminderFrequency => {
  const v = z.string().parse(value)
  if (!reminderFrequencies.includes(v as ReminderFrequency))
    throw new Error(`Invalid reminder frequency: ${v}`)
  return v as ReminderFrequency
}

export const parseCustomIntervalDays = (value: unknown): number => {
  return z
    .preprocess((v) => (typeof v === 'string' ? Number(v) : v), z.number().int().min(1).max(3650))
    .parse(value)
}

export const parseDueDate = (value: unknown): Date => {
  return z.coerce.date().parse(value)
}
