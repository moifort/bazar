import { builder } from '~/domain/shared/graphql/builder'
import { ReminderQuery } from '../../query'
import type { Reminder, ReminderCompletion } from '../../types'
import { ReminderFrequencyEnum } from './enums'

export const ReminderCompletionType = builder
  .objectRef<ReminderCompletion>('ReminderCompletion')
  .implement({
    description: 'A recorded completion of a reminder (historical log)',
    fields: (t) => ({
      id: t.expose('id', { type: 'ReminderCompletionId' }),
      reminderId: t.expose('reminderId', { type: 'ReminderId' }),
      itemId: t.expose('itemId', { type: 'ItemId' }),
      completedAt: t.expose('completedAt', { type: 'DateTime' }),
    }),
  })

export const ReminderType = builder.objectRef<Reminder>('Reminder').implement({
  description: 'A scheduled reminder attached to an item',
  fields: (t) => ({
    id: t.expose('id', { type: 'ReminderId' }),
    itemId: t.expose('itemId', { type: 'ItemId' }),
    title: t.expose('title', { type: 'ReminderTitle' }),
    notes: t.exposeString('notes'),
    dueDate: t.expose('dueDate', { type: 'DateTime' }),
    frequency: t.expose('frequency', { type: ReminderFrequencyEnum, nullable: true }),
    customIntervalDays: t.exposeInt('customIntervalDays', { nullable: true }),
    completions: t.field({
      type: [ReminderCompletionType],
      description: 'Completion history for this reminder, most recent first',
      resolve: (reminder) => ReminderQuery.completionsByReminder(reminder.id),
    }),
    createdAt: t.expose('createdAt', { type: 'DateTime' }),
    updatedAt: t.expose('updatedAt', { type: 'DateTime' }),
  }),
})
