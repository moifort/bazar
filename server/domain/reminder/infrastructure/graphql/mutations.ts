import { GraphQLError } from 'graphql'
import { builder } from '~/domain/shared/graphql/builder'
import { ReminderCommand } from '../../command'
import { AddReminderInput, UpdateReminderInput } from './inputs'
import { ReminderType } from './types'

builder.mutationField('addReminder', (t) =>
  t.field({
    type: ReminderType,
    description: 'Add a new reminder to an item',
    args: { input: t.arg({ type: AddReminderInput, required: true }) },
    resolve: async (_root, { input }, ctx) => {
      const result = await ReminderCommand.add(ctx.userId, input)
      if (result === 'item-not-found')
        throw new GraphQLError('Item not found', { extensions: { code: 'NOT_FOUND' } })
      return result.reminder
    },
  }),
)

builder.mutationField('updateReminder', (t) =>
  t.field({
    type: ReminderType,
    description: 'Update an existing reminder',
    args: {
      id: t.arg({ type: 'ReminderId', required: true }),
      input: t.arg({ type: UpdateReminderInput, required: true }),
    },
    resolve: async (_root, { id, input }, ctx) => {
      const result = await ReminderCommand.update(ctx.userId, id, input)
      if (result === 'not-found')
        throw new GraphQLError('Reminder not found', { extensions: { code: 'NOT_FOUND' } })
      return result.reminder
    },
  }),
)

builder.mutationField('completeReminder', (t) =>
  t.field({
    type: ReminderType,
    nullable: true,
    description:
      'Mark a reminder as done. Recurring reminders reschedule automatically; one-shot reminders are deleted and null is returned.',
    args: { id: t.arg({ type: 'ReminderId', required: true }) },
    resolve: async (_root, { id }, ctx) => {
      const result = await ReminderCommand.complete(ctx.userId, id)
      if (result === 'not-found')
        throw new GraphQLError('Reminder not found', { extensions: { code: 'NOT_FOUND' } })
      if (result.tag === 'done') return null
      return result.reminder
    },
  }),
)

builder.mutationField('deleteReminder', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Delete a reminder',
    args: { id: t.arg({ type: 'ReminderId', required: true }) },
    resolve: async (_root, { id }, ctx) => {
      const result = await ReminderCommand.remove(ctx.userId, id)
      if (result === 'not-found')
        throw new GraphQLError('Reminder not found', { extensions: { code: 'NOT_FOUND' } })
      return true
    },
  }),
)
