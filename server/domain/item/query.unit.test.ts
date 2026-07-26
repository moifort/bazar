import { beforeEach, describe, expect, mock, test } from 'bun:test'
import type { UserId } from '~/domain/shared/types'
import { fakeFirebase, resetFakeFirestore } from '~/test/fake-firestore'

mock.module('~/system/firebase', fakeFirebase)

const { ItemQuery } = await import('./query')

const USER = 'user-1' as UserId

let fake = resetFakeFirestore()

const seedItem = (id: string, over: Record<string, unknown> = {}) =>
  fake.seed('items', id, {
    id,
    userId: USER,
    name: id,
    description: '',
    tags: [],
    personalNotes: '',
    category: 'tools',
    quantity: 1,
    storageId: null,
    zoneId: null,
    placeId: 'place-1',
    purchaseLocation: '',
    createdAt: new Date('2026-01-01'),
    updatedAt: new Date('2026-01-01'),
    ...over,
  })

describe('ItemQuery.allItems', () => {
  beforeEach(() => {
    fake = resetFakeFirestore()
  })

  test('reads one page and one count, never the whole collection', async () => {
    for (let i = 0; i < 50; i++) seedItem(`item-${i}`)

    const page = await ItemQuery.allItems(USER, { limit: 10 })

    expect(page.items).toHaveLength(10)
    expect(page.totalCount).toBe(50)
    expect(page.hasMore).toBe(true)
    // One query for the page, one for the count aggregation — and nothing else.
    expect(fake.queryReads).toBe(2)
  })

  test('filters by category in Firestore', async () => {
    seedItem('a', { category: 'tools' })
    seedItem('b', { category: 'books' })
    seedItem('c', { category: 'books' })

    const page = await ItemQuery.allItems(USER, { category: 'books' })

    expect(page.items.map(({ id }) => id as string).sort()).toEqual(['b', 'c'])
    expect(page.totalCount).toBe(2)
  })

  test('offset pages through the ordered set', async () => {
    seedItem('old', { createdAt: new Date('2026-01-01') })
    seedItem('mid', { createdAt: new Date('2026-02-01') })
    seedItem('new', { createdAt: new Date('2026-03-01') })

    const first = await ItemQuery.allItems(USER, { limit: 2 })
    const second = await ItemQuery.allItems(USER, { limit: 2, offset: 2 })

    // created-at defaults to newest first
    expect(first.items.map(({ id }) => id as string)).toEqual(['new', 'mid'])
    expect(second.items.map(({ id }) => id as string)).toEqual(['old'])
    expect(second.hasMore).toBe(false)
  })

  test('search narrows before paging, so the page stays full', async () => {
    for (let i = 0; i < 20; i++) seedItem(`skip-${i}`)
    for (let i = 0; i < 5; i++) seedItem(`hit-${i}`, { name: `lampe ${i}` })

    const page = await ItemQuery.allItems(USER, { search: 'lampe', limit: 10 })

    expect(page.items).toHaveLength(5)
    expect(page.totalCount).toBe(5)
    expect(page.hasMore).toBe(false)
  })

  test('roomId matches items attached to the room zones and to their storages', async () => {
    fake.seed('zones', 'zone-1', { id: 'zone-1', userId: USER, roomId: 'room-1', order: 0 })
    fake.seed('storages', 'storage-1', {
      id: 'storage-1',
      userId: USER,
      zoneId: 'zone-1',
      order: 0,
    })
    seedItem('on-zone', { zoneId: 'zone-1' })
    seedItem('in-storage', { storageId: 'storage-1' })
    seedItem('elsewhere', { zoneId: 'zone-other' })

    const page = await ItemQuery.allItems(USER, { roomId: 'room-1' })

    expect(page.items.map(({ id }) => id as string).sort()).toEqual(['in-storage', 'on-zone'])
  })
})
