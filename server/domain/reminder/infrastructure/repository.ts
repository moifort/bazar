import { sortBy } from 'lodash-es'
import { createTypedStorage } from '~/system/storage'
import type { Reminder, ReminderCompletion } from '../types'

const remindersStorage = () => createTypedStorage<Reminder>('reminders')
const completionsStorage = () => createTypedStorage<ReminderCompletion>('reminder-completions')

export const findAll = async (): Promise<Reminder[]> => {
  const keys = await remindersStorage().getKeys()
  const entries = await remindersStorage().getItems(keys)
  return sortBy(
    entries.map(({ value }) => value),
    ({ dueDate }) => dueDate,
  )
}

export const findBy = (id: string) => remindersStorage().getItem(id)

export const save = (reminder: Reminder) => remindersStorage().setItem(reminder.id, reminder)

export const remove = (id: string) => remindersStorage().removeItem(id)

export const saveCompletion = (completion: ReminderCompletion) =>
  completionsStorage().setItem(completion.id, completion)

export const findCompletionsByReminder = async (
  reminderId: string,
): Promise<ReminderCompletion[]> => {
  const keys = await completionsStorage().getKeys()
  const entries = await completionsStorage().getItems(keys)
  return sortBy(
    entries.map(({ value }) => value).filter((c) => c.reminderId === reminderId),
    ({ completedAt }) => completedAt,
  ).reverse()
}
