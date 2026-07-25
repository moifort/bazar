import type { PlaceId } from '~/domain/location/types'
import type { UserId } from '~/domain/shared/types'
import { db } from '~/system/firebase'
import { memoizedPerRequest } from '~/system/request-cache'
import { deleteInBatches, genericDataConverter } from '~/utils/firestore'
import type { Item, ItemCategory, ItemId } from '../types'

const items = () => db().collection('items').withConverter(genericDataConverter<Item>())

export const findAllByUser = async (userId: UserId): Promise<Item[]> =>
  memoizedPerRequest(`items:${userId}`, async () => {
    const snap = await items().where('userId', '==', userId).orderBy('createdAt', 'desc').get()
    return snap.docs.map((doc) => doc.data())
  })

// The document field each sort maps to, and the direction meaning "most useful
// first" for it: newest for timestamps, alphabetical for labels.
const SORT_FIELDS = {
  name: { field: 'name', natural: 'asc' },
  category: { field: 'category', natural: 'asc' },
  'created-at': { field: 'createdAt', natural: 'desc' },
  'updated-at': { field: 'updatedAt', natural: 'desc' },
} as const satisfies Record<string, { field: string; natural: 'asc' | 'desc' }>

export type ItemPageArgs = {
  category?: ItemCategory
  placeId?: PlaceId
  sort: keyof typeof SORT_FIELDS
  order?: 'asc' | 'desc'
  offset: number
  limit: number
}

export type ItemPage = { items: Item[]; totalCount: number; hasMore: boolean }

// One page of the user's items, filtered, ordered and sliced by Firestore. The
// total is a count aggregation: one billed round-trip, no documents read.
export const findPage = async (userId: UserId, args: ItemPageArgs): Promise<ItemPage> => {
  const base = () => {
    let query = items().where('userId', '==', userId)
    if (args.category) query = query.where('category', '==', args.category)
    if (args.placeId) query = query.where('placeId', '==', args.placeId)
    return query
  }

  const { field, natural } = SORT_FIELDS[args.sort]
  const snap = await base()
    .orderBy(field, args.order ?? natural)
    .offset(args.offset)
    .limit(args.limit)
    .get()
  const total = await base().count().get()

  const totalCount = total.data().count
  return {
    items: snap.docs.map((doc) => doc.data()),
    totalCount,
    hasMore: args.offset + args.limit < totalCount,
  }
}

export const findBy = async (userId: UserId, id: ItemId): Promise<Item | undefined> => {
  const doc = await items().doc(id).get()
  const data = doc.data()
  return data && data.userId === userId ? data : undefined
}

export const save = async (item: Item): Promise<Item> => {
  await items().doc(item.id).set(item)
  return item
}

export const remove = async (id: ItemId): Promise<void> => {
  await items().doc(id).delete()
}

export const removeAllByUser = async (userId: UserId): Promise<void> => {
  const snap = await items().where('userId', '==', userId).get()
  await deleteInBatches(snap.docs.map((doc) => doc.ref))
}
