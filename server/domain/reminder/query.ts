import type { ItemId } from '~/domain/item/types'
import type { UserId } from '~/domain/shared/types'
import * as repository from './infrastructure/repository'
import type { ReminderId } from './types'

const byItem = (userId: UserId, itemId: ItemId) => repository.findByItem(userId, itemId)

const byId = (userId: UserId, id: ReminderId) => repository.findBy(userId, id)

const remindersDue = (userId: UserId, before: Date) => repository.findDueBefore(userId, before)

const completionsByReminder = (userId: UserId, id: ReminderId) =>
  repository.findCompletionsByReminder(userId, id)

export const ReminderQuery = { byItem, byId, remindersDue, completionsByReminder }
