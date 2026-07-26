import { beforeEach, describe, expect, mock, test } from 'bun:test'
import { graphql } from 'graphql'
import type { UserId } from '~/domain/shared/types'
import { fakeFirebase, resetFakeFirestore } from '~/test/fake-firestore'

mock.module('~/system/firebase', fakeFirebase)

const { schema } = await import('~/domain/shared/graphql/schema')
const { createLoaders } = await import('~/domain/shared/graphql/loaders')

const userId = 'user-1' as UserId

// Ids are UUIDs (the branded scalars reject anything else), so the fixtures use
// readable ones rather than `i1`/`r1`.
const i1 = '11111111-0000-4000-8000-000000000001'
const rem1 = '33333333-0000-4000-8000-000000000001'

let fake = resetFakeFirestore()
beforeEach(() => {
  fake = resetFakeFirestore()
})

// One request = one loader set, exactly as routes/graphql.ts builds it.
const execute = (source: string) =>
  graphql({
    schema,
    source,
    contextValue: { userId, event: undefined as never, loaders: createLoaders(userId) },
  })

const seedItem = () =>
  fake.seed('items', i1, {
    id: i1,
    userId,
    name: 'Machine a cafe',
    description: '',
    tags: [],
    personalNotes: '',
    category: 'appliance',
    quantity: 1,
    addedBy: userId,
    purchaseLocation: '',
    createdAt: new Date('2026-01-01'),
    updatedAt: new Date('2026-01-01'),
  })

// The due date sits far ahead of the run date so the reschedule is computed from
// it, never from "now" — the assertion stays true whenever the suite runs.
const seedReminder = (over: Record<string, unknown> = {}) =>
  fake.seed('reminders', rem1, {
    id: rem1,
    userId,
    itemId: i1,
    title: 'Detartrer',
    notes: '',
    dueDate: new Date('2030-01-15T00:00:00.000Z'),
    createdAt: new Date('2026-01-01'),
    updatedAt: new Date('2026-01-01'),
    ...over,
  })

describe('addReminder mutation', () => {
  test('attaches a recurring reminder to its item', async () => {
    seedItem()

    const result = await execute(`
      mutation {
        addReminder(input: {
          itemId: "${i1}"
          title: "Detartrer"
          dueDate: "2030-01-15T00:00:00.000Z"
          frequency: quarterly
        }) { title frequency customIntervalDays }
      }
    `)
    expect(result.errors).toBeUndefined()
    expect(result.data?.addReminder).toMatchObject({
      title: 'Detartrer',
      frequency: 'quarterly',
      customIntervalDays: null,
    })
  })

  test('refuses an interval on a frequency that is not custom_days', async () => {
    seedItem()

    const result = await execute(`
      mutation {
        addReminder(input: {
          itemId: "${i1}"
          title: "Detartrer"
          dueDate: "2030-01-15T00:00:00.000Z"
          frequency: monthly
          customIntervalDays: 45
        }) { id }
      }
    `)
    expect(result.errors?.[0]?.extensions?.code).toBe('INVALID_FREQUENCY')
    expect(fake.snapshot('reminders').size).toBe(0)
  })

  test('refuses a reminder on an unknown item', async () => {
    const result = await execute(`
      mutation {
        addReminder(input: {
          itemId: "22222222-0000-4000-8000-000000000000"
          title: "Detartrer"
          dueDate: "2030-01-15T00:00:00.000Z"
        }) { id }
      }
    `)
    expect(result.errors?.[0]?.extensions?.code).toBe('ITEM_NOT_FOUND')
    expect(fake.snapshot('reminders').size).toBe(0)
  })
})

describe('completeReminder mutation', () => {
  test('reschedules a recurring reminder and logs the completion', async () => {
    seedItem()
    seedReminder({ frequency: 'custom-days', customIntervalDays: 30 })

    const result = await execute(`
      mutation { completeReminder(id: "${rem1}") { dueDate completions { reminderId } } }
    `)
    expect(result.errors).toBeUndefined()
    expect(result.data?.completeReminder).toMatchObject({
      dueDate: '2030-02-14T00:00:00.000Z',
      completions: [{ reminderId: rem1 }],
    })
    // The reminder survives its completion: it is the same document, moved forward.
    expect(fake.snapshot('reminders').get(rem1)).toMatchObject({ id: rem1 })
    expect(fake.snapshot('reminder-completions').size).toBe(1)
  })

  test('finishes a one-shot reminder: deleted, and null on the wire', async () => {
    seedItem()
    seedReminder()

    const result = await execute(`mutation { completeReminder(id: "${rem1}") { id } }`)
    expect(result.errors).toBeUndefined()
    expect(result.data?.completeReminder).toBeNull()
    expect(fake.snapshot('reminders').size).toBe(0)
    // The history outlives the reminder it came from.
    expect(fake.snapshot('reminder-completions').size).toBe(1)
  })

  test('completing an unknown reminder is a domain error, not a silent success', async () => {
    const result = await execute(
      `mutation { completeReminder(id: "33333333-0000-4000-8000-000000000009") { id } }`,
    )
    expect(result.errors?.[0]?.extensions?.code).toBe('NOT_FOUND')
  })
})
