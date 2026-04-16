import { builder } from '~/domain/shared/graphql/builder'
import { ReminderQuery } from '../../query'
import { ReminderType } from './types'

builder.queryField('remindersDue', (t) =>
  t.field({
    type: [ReminderType],
    description: 'Reminders whose dueDate is on or before the given timestamp',
    args: {
      before: t.arg({ type: 'DateTime', required: true, description: 'Upper bound (inclusive)' }),
    },
    resolve: (_root, { before }) => ReminderQuery.remindersDue(before),
  }),
)
