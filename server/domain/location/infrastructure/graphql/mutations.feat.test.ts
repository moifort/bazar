import { beforeEach, describe, expect, mock, test } from 'bun:test'
import { graphql } from 'graphql'
import type { UserId } from '~/domain/shared/types'
import { fakeFirebase, resetFakeFirestore } from '~/test/fake-firestore'

mock.module('~/system/firebase', fakeFirebase)

const { schema } = await import('~/domain/shared/graphql/schema')
const { createLoaders } = await import('~/domain/shared/graphql/loaders')

const userId = 'user-1' as UserId

// Ids are UUIDs (the branded scalars reject anything else), so the fixtures use
// readable ones rather than `p1`/`r1`.
const p1 = 'aaaaaaaa-0000-4000-8000-000000000001'
const ro1 = 'bbbbbbbb-0000-4000-8000-000000000001'
const z1 = 'cccccccc-0000-4000-8000-000000000001'
const z2 = 'cccccccc-0000-4000-8000-000000000002'
const s1 = 'dddddddd-0000-4000-8000-000000000001'
const i1 = '11111111-0000-4000-8000-000000000001'

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

describe('places query', () => {
  test('returns the four levels nested, each ordered', async () => {
    seedLocationChain()
    fake.seed('zones', z2, { id: z2, userId, roomId: ro1, name: 'Plan de travail', order: 2 })
    // Another user's place never leaks into the tree.
    fake.seed('places', 'aaaaaaaa-0000-4000-8000-000000000009', {
      id: 'aaaaaaaa-0000-4000-8000-000000000009',
      userId: 'user-2',
      name: 'Maison voisine',
      order: 1,
    })

    const result = await execute(`
      query {
        places {
          name
          rooms { name zones { name storages { name } } }
        }
      }
    `)
    expect(result.errors).toBeUndefined()
    expect(result.data?.places).toEqual([
      {
        name: 'Appartement',
        rooms: [
          {
            name: 'Cuisine',
            zones: [
              { name: 'Placard', storages: [{ name: 'Etagere haute' }] },
              { name: 'Plan de travail', storages: [] },
            ],
          },
        ],
      },
    ])
  })

  test('counts the items of a zone through its storages', async () => {
    seedLocationChain()
    fake.seed('items', i1, {
      id: i1,
      userId,
      name: 'Casserole',
      description: '',
      personalNotes: '',
      category: 'kitchenware',
      quantity: 1,
      addedBy: userId,
      purchaseLocation: '',
      storageId: s1,
      placeId: p1,
      createdAt: new Date('2026-01-01'),
      updatedAt: new Date('2026-01-01'),
    })

    const result = await execute(`query { places { rooms { zones { itemCount } } } }`)
    expect(result.errors).toBeUndefined()
    expect(result.data?.places).toEqual([{ rooms: [{ zones: [{ itemCount: 1 }] }] }])
  })
})

describe('createZone mutation', () => {
  test('appends the zone after the last sibling', async () => {
    seedLocationChain()
    fake.seed('zones', z2, { id: z2, userId, roomId: ro1, name: 'Plan de travail', order: 7 })

    const result = await execute(`
      mutation {
        createZone(input: { roomId: "${ro1}", name: "Sous l'evier" }) { name order }
      }
    `)
    expect(result.errors).toBeUndefined()
    // nextOrder is max + 1, not count + 1: a deleted sibling never reopens its slot.
    expect(result.data?.createZone).toMatchObject({ name: "Sous l'evier", order: 8 })
  })

  test('refuses a zone under an unknown room', async () => {
    const result = await execute(`
      mutation {
        createZone(input: { roomId: "bbbbbbbb-0000-4000-8000-000000000009", name: "Placard" }) { id }
      }
    `)
    expect(result.errors?.[0]?.extensions?.code).toBe('NOT_FOUND')
    expect(fake.snapshot('zones').size).toBe(0)
  })
})

describe('deletePlace mutation', () => {
  test('cascades down to the rooms, zones and storages', async () => {
    seedLocationChain()

    const result = await execute(`mutation { deletePlace(id: "${p1}") }`)
    expect(result.errors).toBeUndefined()
    expect(result.data?.deletePlace).toBe(true)
    expect(fake.snapshot('places').size).toBe(0)
    expect(fake.snapshot('rooms').size).toBe(0)
    expect(fake.snapshot('zones').size).toBe(0)
    expect(fake.snapshot('storages').size).toBe(0)
  })

  test('deleting an unknown place is a domain error, not a silent success', async () => {
    const result = await execute(
      `mutation { deletePlace(id: "aaaaaaaa-0000-4000-8000-000000000009") }`,
    )
    expect(result.errors?.[0]?.extensions?.code).toBe('NOT_FOUND')
  })
})
