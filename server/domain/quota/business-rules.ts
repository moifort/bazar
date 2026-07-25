import { QuotaMonth as toQuotaMonth } from '~/domain/quota/primitives'
import type { Quota, QuotaMonth } from '~/domain/quota/types'
import { Count } from '~/domain/shared/primitives'
import type { Count as CountType, Plan, UserId } from '~/domain/shared/types'

// What a free user gets each calendar month. The AI scan is the app's only
// variable cost, so this one number is the whole free tier: the inventory itself,
// the locations, the reminders and the notifications stay unlimited.
export const FREE_MONTHLY_SCANS: CountType = Count(10)

// The ceiling a Premium subscription still answers to, over the last 12 months.
// Not a plan limit and never shown in the app — Premium is sold as "scan without
// counting" — but a subscription is a flat price against a per-call cost, and a
// script driving thousands of scans a month is not a household inventory.
export const PREMIUM_YEARLY_SCANS: CountType = Count(4000)

// How many months the Premium ceiling looks back over, the current one included.
export const PREMIUM_WINDOW_MONTHS = 12

// The month a moment belongs to, `"2026-07"`. UTC on purpose: the window must not
// move with the caller's timezone, and a user near midnight on the 1st is a
// rounding question nobody will ever ask.
export const monthOf = (moment: Date): QuotaMonth =>
  toQuotaMonth(`${moment.getUTCFullYear()}-${String(moment.getUTCMonth() + 1).padStart(2, '0')}`)

// The months the Premium ceiling sums over, newest first, ending at `month`.
// Derived rather than stored: the documents are keyed by month, so the window is
// a list of keys, not a query.
export const windowEndingAt = (month: QuotaMonth, length = PREMIUM_WINDOW_MONTHS): QuotaMonth[] => {
  const [year, index] = (month as string).split('-').map(Number)
  return Array.from({ length }, (_, back) =>
    monthOf(new Date(Date.UTC(year as number, (index as number) - 1 - back, 1))),
  )
}

// When the free counter goes back to zero: midnight UTC on the 1st of the next
// month. `Date.UTC` rolls December over to January on its own.
export const renewsOn = (month: QuotaMonth): Date => {
  const [year, index] = (month as string).split('-').map(Number)
  return new Date(Date.UTC(year as number, index as number, 1))
}

// A month nobody has scanned in yet — what an absent document means.
export const freshQuota = (userId: UserId, month: QuotaMonth): Quota => ({
  userId,
  month,
  scans: Count(0),
})

// How many scans the plan allows per month. Absent for Premium: there is no
// monthly limit to show, and the app shows none.
export const monthlyLimitOf = (plan: Plan): CountType | undefined =>
  plan === 'premium' ? undefined : FREE_MONTHLY_SCANS

// What is left this month, absent when the plan has no monthly limit. Never
// negative: a limit lowered under an already-spent counter reads as zero, not as
// a debt.
export const remaining = (plan: Plan, quota: Quota): CountType | undefined => {
  const limit = monthlyLimitOf(plan)
  return limit === undefined ? undefined : Count(Math.max(0, limit - quota.scans))
}

// Whether the next scan must be refused. A free user is stopped by the month's
// allowance; a Premium one only by the yearly anti-abuse ceiling, which is why it
// takes the whole window rather than a single month.
export const exhausted = (plan: Plan, window: Quota[]): boolean => {
  const spentThisMonth = window[0]?.scans ?? Count(0)
  if (plan === 'free') return spentThisMonth >= FREE_MONTHLY_SCANS
  const spentOverWindow = window.reduce((total, quota) => total + quota.scans, 0)
  return spentOverWindow >= PREMIUM_YEARLY_SCANS
}

// The quota once one scan has been spent.
export const consumed = (quota: Quota): Quota => ({ ...quota, scans: Count(quota.scans + 1) })
