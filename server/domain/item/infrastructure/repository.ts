import type { UserId } from '~/domain/shared/types'
import { db } from '~/system/firebase'
import { genericDataConverter } from '~/utils/firestore'
import type { Item, ItemId } from '../types'

const items = () => db().collection('items').withConverter(genericDataConverter<Item>())

export const findAllByUser = async (userId: UserId): Promise<Item[]> => {
  const snap = await items().where('userId', '==', userId).orderBy('createdAt', 'desc').get()
  return snap.docs.map((doc) => doc.data())
}

export const findBy = async (userId: UserId, id: ItemId): Promise<Item | null> => {
  const doc = await items().doc(id).get()
  const data = doc.data()
  return data && data.userId === userId ? data : null
}

export const save = async (item: Item): Promise<Item> => {
  await items().doc(item.id).set(item)
  return item
}

export const remove = async (id: ItemId): Promise<void> => {
  await items().doc(id).delete()
}
