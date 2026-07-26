import { builder } from '~/domain/shared/graphql/builder'
import { AccountUseCase } from '~/system/account/use-case'

builder.mutationField('deleteAccount', (t) =>
  t.field({
    type: 'Boolean',
    description: [
      'Delete your account and everything the app holds on you: your first name, every item, ' +
        'every place, room, zone and storage spot, every reminder and its completion history, ' +
        'and every device registered for notifications. IRREVERSIBLE and immediate — there is ' +
        'no grace period and no way back. Returns `true` once it is done.',
      '',
      '```graphql',
      'deleteAccount',
      '```',
    ].join('\n'),
    resolve: async (_root, _args, { userId }) => {
      await AccountUseCase.remove(userId)
      return true
    },
  }),
)
