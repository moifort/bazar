import { match, P } from 'ts-pattern'
import { ItemUseCase } from '~/domain/item/use-case'
import { builder } from '~/domain/shared/graphql/builder'
import { domainError } from '~/domain/shared/graphql/errors'
import { ReminderCommand } from '../../command'
import { AddReminderInput, UpdateReminderInput } from './inputs'
import { ReminderType } from './types'

builder.mutationField('addReminder', (t) =>
  t.field({
    type: ReminderType,
    description: 'Add a new reminder to an item',
    args: { input: t.arg({ type: AddReminderInput, required: true }) },
    resolve: async (_root, { input }, ctx) =>
      match(await ItemUseCase.addReminder(ctx.userId, input))
        .with('item-not-found', domainError)
        .with(P.not(P.string), ({ reminder }) => reminder)
        .exhaustive(),
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
    resolve: async (_root, { id, input }, ctx) =>
      match(await ReminderCommand.update(ctx.userId, id, input))
        .with('not-found', domainError)
        .with(P.not(P.string), ({ reminder }) => reminder)
        .exhaustive(),
  }),
)

builder.mutationField('completeReminder', (t) =>
  t.field({
    type: ReminderType,
    nullable: true,
    description:
      'Mark a reminder as done. Recurring reminders reschedule automatically; one-shot reminders are deleted and null is returned.',
    args: { id: t.arg({ type: 'ReminderId', required: true }) },
    resolve: async (_root, { id }, ctx) =>
      match(await ReminderCommand.complete(ctx.userId, id))
        .with('not-found', domainError)
        .with({ tag: 'done' }, () => null)
        .with({ tag: 'rescheduled' }, ({ reminder }) => reminder)
        .exhaustive(),
  }),
)

builder.mutationField('deleteReminder', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Delete a reminder',
    args: { id: t.arg({ type: 'ReminderId', required: true }) },
    resolve: async (_root, { id }, ctx) =>
      match(await ReminderCommand.remove(ctx.userId, id))
        .with('not-found', domainError)
        .with('deleted', () => true)
        .exhaustive(),
  }),
)
