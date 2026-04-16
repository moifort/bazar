import { randomUUID } from 'node:crypto'
import { ItemId } from '~/domain/item/primitives'
import { ItemQuery } from '~/domain/item/query'
import { emit } from '~/system/event-bus'
import { computeNextDueDate, isOneShot } from './business-rules'
import * as repository from './infrastructure/repository'
import {
  parseCustomIntervalDays,
  parseDueDate,
  parseReminderFrequency,
  ReminderCompletionId,
  ReminderId,
  ReminderTitle,
} from './primitives'
import { ReminderQuery } from './query'
import type { Reminder, ReminderCompletion, ReminderFrequency } from './types'

type AddReminderInput = {
  itemId: string
  title: string
  notes?: string | null
  dueDate: Date | string
  frequency?: string | null
  customIntervalDays?: number | null
}

type UpdateReminderInput = {
  title?: string | null
  notes?: string | null
  dueDate?: Date | string | null
  frequency?: string | null
  customIntervalDays?: number | null
}

const resolveFrequency = (
  frequency: string | null | undefined,
  customIntervalDays: number | null | undefined,
): { frequency: ReminderFrequency | null; customIntervalDays: number | null } => {
  if (frequency == null) {
    if (customIntervalDays != null)
      throw new Error('customIntervalDays must be null when frequency is null')
    return { frequency: null, customIntervalDays: null }
  }
  const parsed = parseReminderFrequency(frequency)
  if (parsed === 'custom-days') {
    if (customIntervalDays == null)
      throw new Error('customIntervalDays is required when frequency is custom-days')
    return { frequency: parsed, customIntervalDays: parseCustomIntervalDays(customIntervalDays) }
  }
  if (customIntervalDays != null)
    throw new Error('customIntervalDays must be null unless frequency is custom-days')
  return { frequency: parsed, customIntervalDays: null }
}

const add = async (input: AddReminderInput) => {
  const itemId = ItemId(input.itemId)
  const item = await ItemQuery.itemById(itemId)
  if (!item) return 'item-not-found' as const

  const { frequency, customIntervalDays } = resolveFrequency(
    input.frequency,
    input.customIntervalDays,
  )

  const reminder: Reminder = {
    id: ReminderId(randomUUID()),
    itemId,
    title: ReminderTitle(input.title),
    notes: input.notes ?? '',
    dueDate: parseDueDate(input.dueDate),
    frequency,
    customIntervalDays,
    createdAt: new Date(),
    updatedAt: new Date(),
  }

  await repository.save(reminder)
  await emit('reminder-changed', { type: 'reminder-added' as const, reminder })
  return { tag: 'added' as const, reminder }
}

const update = async (id: string, input: UpdateReminderInput) => {
  const reminderId = ReminderId(id)
  const reminder = await repository.findBy(reminderId)
  if (!reminder) return 'not-found' as const

  const nextFrequency =
    input.frequency !== undefined || input.customIntervalDays !== undefined
      ? resolveFrequency(
          input.frequency !== undefined ? input.frequency : reminder.frequency,
          input.customIntervalDays !== undefined
            ? input.customIntervalDays
            : reminder.customIntervalDays,
        )
      : { frequency: reminder.frequency, customIntervalDays: reminder.customIntervalDays }

  const updated: Reminder = {
    ...reminder,
    title: input.title ? ReminderTitle(input.title) : reminder.title,
    notes: input.notes !== undefined ? (input.notes ?? '') : reminder.notes,
    dueDate: input.dueDate ? parseDueDate(input.dueDate) : reminder.dueDate,
    frequency: nextFrequency.frequency,
    customIntervalDays: nextFrequency.customIntervalDays,
    updatedAt: new Date(),
  }

  await repository.save(updated)
  await emit('reminder-changed', { type: 'reminder-updated' as const, reminder: updated })
  return { tag: 'updated' as const, reminder: updated }
}

const complete = async (id: string, completedAt: Date = new Date()) => {
  const reminderId = ReminderId(id)
  const reminder = await repository.findBy(reminderId)
  if (!reminder) return 'not-found' as const

  const completion: ReminderCompletion = {
    id: ReminderCompletionId(randomUUID()),
    reminderId: reminder.id,
    itemId: reminder.itemId,
    completedAt,
  }
  await repository.saveCompletion(completion)

  if (isOneShot(reminder.frequency)) {
    await repository.remove(reminder.id)
    await emit('reminder-changed', {
      type: 'reminder-completed' as const,
      reminder: null,
      completion,
    })
    await emit('reminder-changed', {
      type: 'reminder-deleted' as const,
      reminderId: reminder.id,
    })
    return { tag: 'done' as const, completion }
  }

  const nextDueDate = computeNextDueDate(
    reminder.dueDate,
    // biome-ignore lint/style/noNonNullAssertion: isOneShot false implies frequency !== null
    reminder.frequency!,
    reminder.customIntervalDays,
    completedAt,
  )
  const rescheduled: Reminder = { ...reminder, dueDate: nextDueDate, updatedAt: new Date() }
  await repository.save(rescheduled)
  await emit('reminder-changed', {
    type: 'reminder-completed' as const,
    reminder: rescheduled,
    completion,
  })
  return { tag: 'rescheduled' as const, reminder: rescheduled, completion }
}

const remove = async (id: string) => {
  const reminderId = ReminderId(id)
  const reminder = await repository.findBy(reminderId)
  if (!reminder) return 'not-found' as const

  await repository.remove(reminderId)
  await emit('reminder-changed', { type: 'reminder-deleted' as const, reminderId })
  return 'deleted' as const
}

const removeByItem = async (itemId: string) => {
  const reminders = await ReminderQuery.byItem(ItemId(itemId))
  await Promise.all(
    reminders.map(async (r) => {
      await repository.remove(r.id)
      await emit('reminder-changed', {
        type: 'reminder-deleted' as const,
        reminderId: r.id,
      })
    }),
  )
}

export const ReminderCommand = { add, update, complete, remove, removeByItem }
