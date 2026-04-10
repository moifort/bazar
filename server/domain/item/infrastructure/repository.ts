import { sortBy } from 'lodash-es'
import { createTypedStorage } from '~/system/storage'
import type { Item } from '../types'

const itemsStorage = () => createTypedStorage<Item>('items')

export const findAll = async () => {
  const keys = await itemsStorage().getKeys()
  const items = await itemsStorage().getItems(keys)
  return sortBy(
    items.map(({ value }) => value),
    ({ createdAt }) => createdAt,
  ).reverse()
}

export const findBy = (id: string) => itemsStorage().getItem(id)

export const save = (item: Item) => itemsStorage().setItem(item.id, item)

export const remove = (id: string) => itemsStorage().removeItem(id)
