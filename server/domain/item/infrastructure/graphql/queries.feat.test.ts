import { beforeEach, describe, expect, mock, test } from 'bun:test'
import { graphql } from 'graphql'
import type { UserId } from '~/domain/shared/types'
import { fakeDb, resetFakeFirestore } from '~/test/fake-firestore'

mock.module('~/system/firebase', () => ({ db: fakeDb }))

const { schema } = await import('~/domain/shared/graphql/schema')
const { createLoaders } = await import('~/domain/shared/graphql/loaders')

const userId = 'user-1' as UserId

// Ids are UUIDs (the branded scalars reject anything else), so the fixtures use
// readable ones rather than `p1`/`i1`.
const p1 = 'aaaaaaaa-0000-4000-8000-000000000001'
const ro1 = 'bbbbbbbb-0000-4000-8000-000000000001'
const z1 = 'cccccccc-0000-4000-8000-000000000001'
const s1 = 'dddddddd-0000-4000-8000-000000000001'
const itemId = (n: number) => `11111111-0000-4000-8000-${String(n).padStart(12, '0')}`

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

const seedLocationChain = () => {
  fake.seed('places', p1, { id: p1, userId, name: 'Appartement', order: 1 })
  fake.seed('rooms', ro1, { id: ro1, userId, placeId: p1, name: 'Cuisine', order: 1 })
  fake.seed('zones', z1, { id: z1, userId, roomId: ro1, name: 'Placard', order: 1 })
  fake.seed('storages', s1, { id: s1, userId, zoneId: z1, name: 'Etagere haute', order: 1 })
}

const seedItem = (id: string, over: Record<string, unknown> = {}) =>
  fake.seed('items', id, {
    id,
    userId,
    name: `Objet ${id.slice(-2)}`,
    description: '',
    personalNotes: '',
    category: 'kitchenware',
    quantity: 1,
    addedBy: userId,
    purchaseLocation: '',
    createdAt: new Date('2026-01-01'),
    updatedAt: new Date('2026-01-01'),
    ...over,
  })

describe('items query', () => {
  test('pages, counts and scopes to the owner', async () => {
    seedLocationChain()
    for (let n = 1; n <= 3; n++) seedItem(itemId(n), { storageId: s1, placeId: p1 })
    // Another user's item never leaks into the page or the count.
    seedItem(itemId(9), { userId: 'user-2', addedBy: 'user-2' })

    const result = await execute(`
      query {
        items(limit: 2, sort: name, order: asc) {
          totalCount
          hasMore
          items { name location { fullPath } }
        }
      }
    `)
    expect(result.errors).toBeUndefined()
    expect(result.data?.items).toMatchObject({
      totalCount: 3,
      hasMore: true,
      items: [
        {
          name: 'Objet 01',
          location: { fullPath: 'Appartement > Cuisine > Placard > Etagere haute' },
        },
        {
          name: 'Objet 02',
          location: { fullPath: 'Appartement > Cuisine > Placard > Etagere haute' },
        },
      ],
    })
  })

  test('resolves a whole page of locations without one read per item', async () => {
    seedLocationChain()
    for (let n = 1; n <= 10; n++) seedItem(itemId(n), { storageId: s1, placeId: p1 })

    // Exactly what the inventory list asks for.
    const result = await execute(`
      query {
        items(limit: 10) {
          totalCount
          items { name location { fullPath } }
        }
      }
    `)
    expect(result.errors).toBeUndefined()
    // One page scan + one count, then the four location collections once each —
    // however many items sit on the page.
    expect(fake.docReads).toBe(0)
    expect(fake.queryReads).toBe(6)
  })

  test('an unknown item resolves to null, not an error', async () => {
    const result = await execute(`
      query { item(id: "22222222-0000-4000-8000-000000000000") { id } }
    `)
    expect(result.errors).toBeUndefined()
    expect(result.data?.item).toBeNull()
  })
})
