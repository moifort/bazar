import { builder } from '~/domain/shared/graphql/builder'

export const PlanEnum = builder.enumType('Plan', {
  description:
    'What a user is entitled to. The inventory itself is free and unlimited — the plan only ' +
    'decides how many photo scans come with it.',
  values: {
    FREE: {
      value: 'free',
      description: 'The free plan — unlimited items, a monthly allowance of photo scans',
    },
    PREMIUM: {
      value: 'premium',
      description: 'The paid subscription — photo scans with no monthly allowance to watch',
    },
  } as const,
})
