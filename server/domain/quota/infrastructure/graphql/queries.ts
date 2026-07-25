import { EntitlementQuery } from '~/domain/entitlement/query'
import { QuotaQuery } from '~/domain/quota/query'
import { builder } from '~/domain/shared/graphql/builder'
import { QuotaType } from './types'

builder.queryField('quota', (t) =>
  t.field({
    type: QuotaType,
    description: [
      'Your photo-scan allowance for the current month: the plan you are on, what you have ' +
        'spent, what is left and when it renews. The free plan gets 10 scans a month; Premium ' +
        'has no monthly allowance, so `limit` and `remaining` come back `null`.',
      '',
      '```graphql',
      'quota {',
      '  plan',
      '  used',
      '  limit',
      '  remaining',
      '  renewsOn',
      '}',
      '```',
    ].join('\n'),
    resolve: async (_root, _args, { userId }) => ({
      plan: await EntitlementQuery.planOf(userId),
      quota: await QuotaQuery.current(userId),
    }),
  }),
)
