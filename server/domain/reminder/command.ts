import { randomUUID } from 'node:crypto'
import type { ItemId } from '~/domain/item/types'
import type { UserId } from '~/domain/shared/types'
import { emit } from '~/system/event-bus'
import { isOneShot, nextDueDate } from './business-rules'
import * as repository from './infrastructure/repository'
import {
  ReminderCompletionId as makeReminderCompletionId,
  ReminderId as makeReminderId,
  parseCustomIntervalDays,
  parseDueDate,
  parseReminderFrequency,
  ReminderTitle,
} from './primitives'
import type { Reminder, ReminderCompletion, ReminderFrequency, ReminderId } from './types'

type AddReminderInput = {
  itemId: ItemId
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

type ResolvedFrequency = { frequency?: ReminderFrequency; customIntervalDays?: number }

// `customIntervalDays` belongs to `custom-days` and to nothing else: a one-shot
// reminder carries no interval, and a fixed frequency derives its own. Breaking
// that pairing is a caller error, reported as a sentinel — never thrown.
const resolveFrequency = (
  frequency: string | null | undefined,
  customIntervalDays: number | null | undefined,
): ResolvedFrequency | 'invalid-frequency' => {
  if (frequency == null) {
    if (customIntervalDays != null) return 'invalid-frequency'
    return {}
  }
  const parsed = parseReminderFrequency(frequency)
  if (parsed === 'custom-days') {
    if (customIntervalDays == null) return 'invalid-frequency'
    return { frequency: parsed, customIntervalDays: parseCustomIntervalDays(customIntervalDays) }
  }
  if (customIntervalDays != null) return 'invalid-frequency'
  return { frequency: parsed }
}

// The item's existence is checked by the caller that owns it (`ItemUseCase`);
// here `itemId` is an opaque reference.
const add = async (userId: UserId, input: AddReminderInput) => {
  const resolved = resolveFrequency(input.frequency, input.customIntervalDays)
  if (resolved === 'invalid-frequency') return resolved
  const { frequency, customIntervalDays } = resolved

  const reminder: Reminder = {
    id: makeReminderId(randomUUID()),
    userId,
    itemId: input.itemId,
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

const update = async (userId: UserId, id: ReminderId, input: UpdateReminderInput) => {
  const reminder = await repository.findBy(userId, id)
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
  if (nextFrequency === 'invalid-frequency') return nextFrequency

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

const complete = async (userId: UserId, id: ReminderId, completedAt: Date = new Date()) => {
  const reminder = await repository.findBy(userId, id)
  if (!reminder) return 'not-found' as const

  const completion: ReminderCompletion = {
    id: makeReminderCompletionId(randomUUID()),
    userId,
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

  const rescheduled: Reminder = {
    ...reminder,
    dueDate: nextDueDate(
      reminder.dueDate,
      // biome-ignore lint/style/noNonNullAssertion: isOneShot false implies frequency !== null
      reminder.frequency!,
      reminder.customIntervalDays,
      completedAt,
    ),
    updatedAt: new Date(),
  }
  await repository.save(rescheduled)
  await emit('reminder-changed', {
    type: 'reminder-completed' as const,
    reminder: rescheduled,
    completion,
  })
  return { tag: 'rescheduled' as const, reminder: rescheduled, completion }
}

const remove = async (userId: UserId, id: ReminderId) => {
  const reminder = await repository.findBy(userId, id)
  if (!reminder) return 'not-found' as const

  await repository.remove(id)
  await emit('reminder-changed', { type: 'reminder-deleted' as const, reminderId: id })
  return 'deleted' as const
}

const removeByItem = async (userId: UserId, itemId: ItemId) => {
  const reminders = await repository.findByItem(userId, itemId)
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

const forget = (userId: UserId): Promise<void> => repository.removeAllByUser(userId)

export const ReminderCommand = { add, update, complete, remove, removeByItem, forget }
