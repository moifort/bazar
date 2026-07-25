import { beforeEach, describe, expect, mock, test } from 'bun:test'
import type { UserId } from '~/domain/shared/types'
import { fakeFirebase, resetFakeFirestore } from '~/test/fake-firestore'

mock.module('~/system/firebase', fakeFirebase)

const { QuotaCommand } = await import('~/domain/quota/command')
const { QuotaQuery } = await import('~/domain/quota/query')
const { monthOf, windowEndingAt, FREE_MONTHLY_SCANS, PREMIUM_YEARLY_SCANS } = await import(
  '~/domain/quota/business-rules'
)

const userId = 'user-1' as UserId
const other = 'user-2' as UserId

let fake = resetFakeFirestore()
beforeEach(() => {
  fake = resetFakeFirestore()
})

const thisMonth = () => monthOf(new Date())
const docId = (month: string, owner: UserId = userId) => `${owner}_${month}`

const seedScans = (month: string, scans: number, owner: UserId = userId) =>
  fake.seed('scan-quotas', docId(month, owner), { userId: owner, month, scans })

describe('QuotaCommand.record', () => {
  test('opens this month at one when nothing was spent yet', async () => {
    const quota = await QuotaCommand.record(userId)

    expect(quota.scans as number).toBe(1)
    // An absent document is a fresh month, not a missing one: no seeding, no
    // scheduled job creating next month's counters.
    expect(fake.snapshot('scan-quotas').get(docId(thisMonth()))).toMatchObject({ scans: 1 })
  })

  test('counts every scan, not every request', async () => {
    await QuotaCommand.record(userId)
    await QuotaCommand.record(userId)

    expect(fake.snapshot('scan-quotas').get(docId(thisMonth()))).toMatchObject({ scans: 2 })
  })

  test('leaves last month and every other user alone', async () => {
    seedScans('2020-01', 7)
    seedScans(thisMonth(), 4, other)

    await QuotaCommand.record(userId)

    expect(fake.snapshot('scan-quotas').get(docId('2020-01'))).toMatchObject({ scans: 7 })
    expect(fake.snapshot('scan-quotas').get(docId(thisMonth(), other))).toMatchObject({ scans: 4 })
  })
})

describe('QuotaQuery.exhaustedFor', () => {
  test('a free user is refused once the month is spent', async () => {
    seedScans(thisMonth(), FREE_MONTHLY_SCANS - 1)
    expect(await QuotaQuery.exhaustedFor(userId, 'free')).toBe(false)

    await QuotaCommand.record(userId)
    // The record evicts the memoized pre-write value: a second check in the same
    // request must see what was just spent, not the number it was allowed on.
    expect(await QuotaQuery.exhaustedFor(userId, 'free')).toBe(true)
  })

  test('a free user is decided by this month alone — one read, not twelve', async () => {
    seedScans(thisMonth(), 1)
    const before = fake.reads

    await QuotaQuery.exhaustedFor(userId, 'free')

    expect(fake.reads - before).toBe(1)
  })

  test('a premium user is never stopped by a single month', async () => {
    seedScans(thisMonth(), FREE_MONTHLY_SCANS * 10)

    expect(await QuotaQuery.exhaustedFor(userId, 'premium')).toBe(false)
  })

  test('a premium user is stopped by the twelve-month ceiling', async () => {
    const window = windowEndingAt(thisMonth())
    for (const month of window) seedScans(month, PREMIUM_YEARLY_SCANS / 12)

    expect(await QuotaQuery.exhaustedFor(userId, 'premium')).toBe(true)
  })

  test('the ceiling looks back exactly twelve months, not further', async () => {
    // A thirteenth month of heavy use has rolled out of the window: it must not
    // keep a subscriber blocked forever.
    const window = windowEndingAt(thisMonth(), 13)
    const stale = window[12] as string
    seedScans(stale, PREMIUM_YEARLY_SCANS)

    expect(await QuotaQuery.exhaustedFor(userId, 'premium')).toBe(false)
  })

  test('the premium window is read by key — twelve document gets, no scan', async () => {
    const before = { docs: fake.docReads, queries: fake.queryReads }

    await QuotaQuery.exhaustedFor(userId, 'premium')

    expect(fake.docReads - before.docs).toBe(12)
    expect(fake.queryReads - before.queries).toBe(0)
  })
})

describe('QuotaCommand.forget', () => {
  test('erases every month the user ever scanned in', async () => {
    seedScans('2026-01', 3)
    seedScans('2026-02', 5)
    seedScans(thisMonth(), 1, other)

    await QuotaCommand.forget(userId)

    expect([...fake.snapshot('scan-quotas').keys()]).toEqual([docId(thisMonth(), other)])
  })
})
