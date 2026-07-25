import { monthlyLimitOf, remaining, renewsOn } from '~/domain/quota/business-rules'
import type { Quota } from '~/domain/quota/types'
import { builder } from '~/domain/shared/graphql/builder'
import type { Plan } from '~/domain/shared/types'
import { PlanEnum } from './enums'

// What the `quota` query answers: the plan, and this month's consumption under it.
export type QuotaState = { plan: Plan; quota: Quota }

export const QuotaType = builder.objectRef<QuotaState>('Quota').implement({
  description:
    'Your photo-scan allowance for the current calendar month. Items, locations and reminders ' +
    'are never limited: only the AI scan is, and it resets on the 1st.',
  fields: (t) => ({
    plan: t.field({
      type: PlanEnum,
      description: 'The plan in force, e.g. `FREE`',
      resolve: (state) => state.plan,
    }),
    used: t.int({
      description: 'How many scans were spent this month, e.g. `3`',
      resolve: (state) => state.quota.scans,
    }),
    // `limit` and `remaining` are absent on a plan with no monthly allowance —
    // the domain says "no limit" by absence, GraphQL says it with `null`, and the
    // two are bridged here (the only place they meet).
    limit: t.int({
      nullable: true,
      description: 'How many scans the plan allows per month, e.g. `10` — `null` on Premium',
      resolve: (state) => monthlyLimitOf(state.plan) ?? null,
    }),
    remaining: t.int({
      nullable: true,
      description: 'How many scans are still available this month, e.g. `7` — `null` on Premium',
      resolve: (state) => remaining(state.plan, state.quota) ?? null,
    }),
    renewsOn: t.field({
      type: 'DateTime',
      description:
        'When the counter goes back to zero — the 1st of next month, e.g. ' +
        '`"2026-08-01T00:00:00.000Z"`',
      resolve: (state) => renewsOn(state.quota.month),
    }),
  }),
})
