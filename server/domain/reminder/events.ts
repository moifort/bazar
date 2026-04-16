import type { Reminder, ReminderCompletion, ReminderId } from './types'

export type ReminderEvent =
  | { type: 'reminder-added'; reminder: Reminder }
  | { type: 'reminder-updated'; reminder: Reminder }
  | { type: 'reminder-completed'; reminder: Reminder | null; completion: ReminderCompletion }
  | { type: 'reminder-deleted'; reminderId: ReminderId }
