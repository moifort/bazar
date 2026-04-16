import { sortBy } from 'lodash-es'
import type { ItemId } from '~/domain/item/types'
import * as repository from './infrastructure/repository'
import type { ReminderId } from './types'

const byItem = async (itemId: ItemId) => {
  const all = await repository.findAll()
  return sortBy(
    all.filter((r) => r.itemId === itemId),
    ({ dueDate }) => dueDate,
  )
}

const byId = (id: ReminderId) => repository.findBy(id)

const remindersDue = async (before: Date) => {
  const all = await repository.findAll()
  return sortBy(
    all.filter((r) => r.dueDate.getTime() <= before.getTime()),
    ({ dueDate }) => dueDate,
  )
}

const completionsByReminder = (id: ReminderId) => repository.findCompletionsByReminder(id)

export const ReminderQuery = { byItem, byId, remindersDue, completionsByReminder }
