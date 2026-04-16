import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  ItemCategory,
  ItemId as ItemIdType,
  ItemName as ItemNameType,
  ItemSort,
  Quantity as QuantityType,
} from '~/domain/item/types'

export const ItemId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<ItemIdType>()(v)
}

export const ItemName = (value: unknown) => {
  const v = z.string().min(1).max(500).parse(value)
  return make<ItemNameType>()(v)
}

export const Quantity = (value: unknown) => {
  const v = z
    .preprocess((v) => (typeof v === 'string' ? Number(v) : v), z.number().int().positive())
    .parse(value)
  return make<QuantityType>()(v)
}

const itemCategories: ItemCategory[] = [
  'tools',
  'appliances',
  'decor',
  'clothing',
  'documents',
  'food',
  'electronics',
  'furniture',
  'kitchenware',
  'linen',
  'sports',
  'toys',
  'books',
  'media',
  'hygiene',
  'other',
]

export const parseItemCategory = (value: unknown): ItemCategory => {
  const v = z.string().parse(value)
  if (!itemCategories.includes(v as ItemCategory)) throw new Error(`Invalid item category: ${v}`)
  return v as ItemCategory
}

const itemSorts: ItemSort[] = ['name', 'category', 'created-at', 'updated-at']

export const parseItemSort = (value: unknown): ItemSort => {
  const v = z.string().parse(value)
  if (!itemSorts.includes(v as ItemSort)) throw new Error(`Invalid item sort: ${v}`)
  return v as ItemSort
}

export const parsePurchaseLocation = (value: unknown): string => {
  return z.string().max(200).parse(value).trim()
}

export const parsePurchaseDate = (value: unknown): Date => {
  return z.coerce.date().parse(value)
}
