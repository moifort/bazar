import { builder } from '~/domain/shared/graphql/builder'
import type { User } from '~/domain/user/types'

export const UserType = builder.objectRef<User>('User').implement({
  description:
    'Who the signed-in account belongs to, as the user introduced themselves during the ' +
    'onboarding. It only exists once that onboarding is done.',
  fields: (t) => ({
    firstName: t.expose('firstName', {
      type: 'FirstName',
      description: 'How to call the user, e.g. `"Thibaut"`',
    }),
    onboardedOn: t.field({
      type: 'DateTime',
      description: 'When the user went through the onboarding, e.g. `"2026-07-26T09:12:00.000Z"`',
      resolve: (user) => user.onboardedAt,
    }),
  }),
})
