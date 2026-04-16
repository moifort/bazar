import { builder } from '~/domain/shared/graphql/builder'

export const ReminderFrequencyEnum = builder.enumType('ReminderFrequency', {
  description: 'Recurrence cadence for a reminder',
  values: {
    monthly: { value: 'monthly', description: 'Every month' },
    quarterly: { value: 'quarterly', description: 'Every three months' },
    biannual: { value: 'biannual', description: 'Every six months' },
    annual: { value: 'annual', description: 'Every year' },
    custom_days: { value: 'custom-days', description: 'Custom number of days' },
  },
})
