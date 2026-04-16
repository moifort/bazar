import { builder } from '~/domain/shared/graphql/builder'
import { ReminderFrequencyEnum } from './enums'

export const AddReminderInput = builder.inputType('AddReminderInput', {
  description: 'Input for adding a new reminder to an item',
  fields: (t) => ({
    itemId: t.field({ type: 'ItemId', required: true, description: 'Target item' }),
    title: t.field({ type: 'ReminderTitle', required: true, description: 'Reminder title' }),
    notes: t.string({ description: 'Free-form notes' }),
    dueDate: t.field({ type: 'DateTime', required: true, description: 'Next due date' }),
    frequency: t.field({
      type: ReminderFrequencyEnum,
      description: 'Recurrence cadence (omit for one-shot)',
    }),
    customIntervalDays: t.int({
      description: 'Days between occurrences when frequency is custom_days',
    }),
  }),
})

export const UpdateReminderInput = builder.inputType('UpdateReminderInput', {
  description: 'Input for updating an existing reminder',
  fields: (t) => ({
    title: t.field({ type: 'ReminderTitle', description: 'New title' }),
    notes: t.string({ description: 'New notes' }),
    dueDate: t.field({ type: 'DateTime', description: 'New due date' }),
    frequency: t.field({
      type: ReminderFrequencyEnum,
      description: 'New recurrence cadence (explicit null clears it)',
    }),
    customIntervalDays: t.int({
      description: 'Custom interval in days (only when frequency is custom_days)',
    }),
  }),
})
