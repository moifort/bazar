import { exhausted, monthOf, windowEndingAt } from '~/domain/quota/business-rules'
import * as repository from '~/domain/quota/infrastructure/repository'
import type { Quota } from '~/domain/quota/types'
import type { Plan, UserId } from '~/domain/shared/types'

export namespace QuotaQuery {
  // This month's consumption for that user — zero until the first scan.
  export const current = async (userId: UserId): Promise<Quota> =>
    repository.findBy(userId, monthOf(new Date()))

  // Whether the next scan must be refused. Asked before the AI is called, so a
  // refusal costs nothing. The plan comes from the caller: what a user is
  // entitled to is the `entitlement` domain's business, never storage this
  // domain reads.
  //
  // A free user is decided by this month alone, so it costs one read; Premium is
  // decided by the twelve-month ceiling, which costs twelve keyed reads and only
  // happens for subscribers.
  export const exhaustedFor = async (userId: UserId, plan: Plan): Promise<boolean> => {
    const month = monthOf(new Date())
    if (plan === 'free') return exhausted(plan, [await repository.findBy(userId, month)])
    return exhausted(plan, await repository.findWindow(userId, windowEndingAt(month)))
  }
}
