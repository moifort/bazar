import { beforeEach, describe, expect, mock, test } from 'bun:test'
import { graphql } from 'graphql'
import type { UserId } from '~/domain/shared/types'
import { fakeDb, resetFakeFirestore } from '~/test/fake-firestore'

mock.module('~/system/firebase', () => ({ db: fakeDb }))

const { schema } = await import('~/domain/shared/graphql/schema')
const { createLoaders } = await import('~/domain/shared/graphql/loaders')

const userId = 'user-1' as UserId

const p1 = 'aaaaaaaa-0000-4000-8000-000000000001'
const ro1 = 'bbbbbbbb-0000-4000-8000-000000000001'
const z1 = 'cccccccc-0000-4000-8000-000000000001'
const s1 = 'dddddddd-0000-4000-8000-000000000001'
const i1 = '11111111-0000-4000-8000-000000000001'
const rem1 = '33333333-0000-4000-8000-000000000001'
const rem2 = '33333333-0000-4000-8000-000000000002'

let fake = resetFakeFirestore()
beforeEach(() => {
  fake = resetFakeFirestore()
})

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

describe('addItem mutation', () => {
  test('creates the item attached to its storage, place denormalised', async () => {
    seedLocationChain()

    const result = await execute(`
      mutation {
        addItem(input: { name: "Casserole", category: kitchenware, quantity: 2, storageId: "${s1}" }) {
          name
          quantity
          location { fullPath }
        }
      }
    `)
    expect(result.errors).toBeUndefined()
    expect(result.data?.addItem).toMatchObject({
      name: 'Casserole',
      quantity: 2,
      location: { fullPath: 'Appartement > Cuisine > Placard > Etagere haute' },
    })

    const [stored] = [...fake.snapshot('items').values()]
    // The place is written at attach time, so listing by place never walks the tree.
    expect(stored).toMatchObject({ storageId: s1, placeId: p1 })
  })

  test('refuses an item attached to a storage AND a zone', async () => {
    seedLocationChain()

    const result = await execute(`
      mutation {
        addItem(input: { name: "Casserole", category: kitchenware, storageId: "${s1}", zoneId: "${z1}" }) {
          id
        }
      }
    `)
    expect(result.errors?.[0]?.extensions?.code).toBe('INVALID_LOCATION')
    expect(fake.snapshot('items').size).toBe(0)
  })
})

describe('deleteItem mutation', () => {
  test('deletes the item together with its reminders', async () => {
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
      createdAt: new Date('2026-01-01'),
      updatedAt: new Date('2026-01-01'),
    })
    for (const id of [rem1, rem2]) {
      fake.seed('reminders', id, {
        id,
        userId,
        itemId: i1,
        title: 'Detartrer',
        notes: '',
        dueDate: new Date('2026-08-01'),
        createdAt: new Date('2026-01-01'),
        updatedAt: new Date('2026-01-01'),
      })
    }

    const result = await execute(`mutation { deleteItem(id: "${i1}") }`)
    expect(result.errors).toBeUndefined()
    expect(result.data?.deleteItem).toBe(true)
    expect(fake.snapshot('items').size).toBe(0)
    expect(fake.snapshot('reminders').size).toBe(0)
  })

  test('deleting an unknown item is a domain error, not a silent success', async () => {
    const result = await execute(
      `mutation { deleteItem(id: "22222222-0000-4000-8000-000000000000") }`,
    )
    expect(result.errors?.[0]?.extensions?.code).toBe('NOT_FOUND')
  })
})
