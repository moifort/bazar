import type { Brand } from 'ts-brand'
import type { ItemId } from '~/domain/item/types'
import type { UserId } from '~/domain/shared/types'

export type ReminderId = Brand<string, 'ReminderId'>
export type ReminderCompletionId = Brand<string, 'ReminderCompletionId'>
export type ReminderTitle = Brand<string, 'ReminderTitle'>

export type ReminderFrequency = 'monthly' | 'quarterly' | 'biannual' | 'annual' | 'custom-days'

export type Reminder = {
  id: ReminderId
  userId: UserId
  itemId: ItemId
  title: ReminderTitle
  notes: string
  dueDate: Date
  frequency: ReminderFrequency | null
  customIntervalDays: number | null
  createdAt: Date
  updatedAt: Date
}

export type ReminderCompletion = {
  id: ReminderCompletionId
  userId: UserId
  reminderId: ReminderId
  itemId: ItemId
  completedAt: Date
}
