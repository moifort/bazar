import { builder } from '~/domain/shared/graphql/builder'
import { UserQuery } from '~/domain/user/query'
import { UserType } from './types'

builder.queryField('me', (t) =>
  t.field({
    type: UserType,
    nullable: true,
    description: [
      'Who you are, as you introduced yourself. `null` means you never went through the ' +
        'onboarding — which is exactly what the app reads on launch to decide whether to run it.',
      '',
      '```graphql',
      'me {',
      '  firstName',
      '  onboardedOn',
      '}',
      '```',
    ].join('\n'),
    resolve: async (_root, _args, { userId }) => (await UserQuery.of(userId)) ?? null,
  }),
)
