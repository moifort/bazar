import { beforeEach, describe, expect, mock, test } from 'bun:test'
import type { UserId } from '~/domain/shared/types'
import { fakeFirebase, resetFakeFirestore } from '~/test/fake-firestore'

mock.module('~/system/firebase', fakeFirebase)

const { SearchQuery } = await import('./query')

const USER = 'user-1' as UserId
const i1 = '11111111-0000-4000-8000-000000000001'

let fake = resetFakeFirestore()

const seedItem = (over: Record<string, unknown> = {}) =>
  fake.seed('items', i1, {
    id: i1,
    userId: USER,
    name: "Pot d'epices",
    description: '',
    tags: [],
    personalNotes: '',
    category: 'food',
    quantity: 12,
    addedBy: USER,
    purchaseLocation: '',
    createdAt: new Date('2026-01-01'),
    updatedAt: new Date('2026-01-01'),
    ...over,
  })

describe('SearchQuery.search', () => {
  beforeEach(() => {
    fake = resetFakeFirestore()
  })

  test('finds an item by a label read on one of the units it groups', async () => {
    seedItem({ tags: ['cumin', 'paprika', 'condiment'] })

    const results = await SearchQuery.search(USER, 'paprika')

    expect(results).toEqual([{ type: 'item', entityId: i1, text: expect.any(String) }])
  })

  test('finds the same item by a word describing it', async () => {
    seedItem({ tags: ['cumin', 'paprika', 'condiment'] })

    const results = await SearchQuery.search(USER, 'condiment')

    expect(results.map(({ entityId }) => entityId)).toEqual([i1])
  })

  test('an item without keywords is still found by its name', async () => {
    seedItem()

    const results = await SearchQuery.search(USER, 'pot')

    expect(results.map(({ entityId }) => entityId)).toEqual([i1])
  })
})
