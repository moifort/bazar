import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  ItemCategory,
  ItemId as ItemIdType,
  ItemName as ItemNameType,
  ItemSort,
  ItemTag as ItemTagType,
  LowStockThreshold as LowStockThresholdType,
  PurchaseCondition,
  Quantity as QuantityType,
} from '~/domain/item/types'
import { normalizeText } from '~/utils/text'

export const ItemId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<ItemIdType>()(v)
}

export const ItemName = (value: unknown) => {
  const v = z.string().min(1).max(500).parse(value)
  return make<ItemNameType>()(v)
}

// A tag holds a label copied off the object as often as a keyword describing
// it, so the ceiling has to fit a whole printed line ("Confiture de fraises
// extra bio 370 g"), not just a word.
export const ItemTag = (value: unknown) => {
  const v = z.string().trim().min(1).max(200).parse(value)
  return make<ItemTagType>()(v)
}

// Every readable label goes in — the list is not capped. What is dropped is
// only what says nothing new: a blank, and a keyword already there under a
// different case or accent. First spelling wins, so the labels read on the
// units keep the order the AI listed them in, ahead of the descriptive words.
export const parseItemTags = (values: unknown): ItemTagType[] => {
  const raw = z.array(z.string()).parse(values)
  const seen = new Set<string>()
  const tags: ItemTagType[] = []

  for (const value of raw) {
    // A blank is what an untouched input field sends, not a rejected tag.
    if (value.trim().length === 0) continue

    const key = normalizeText(value)
    if (seen.has(key)) continue
    seen.add(key)
    tags.push(ItemTag(value))
  }

  return tags
}

export const Quantity = (value: unknown) => {
  const v = z
    .preprocess((v) => (typeof v === 'string' ? Number(v) : v), z.number().int().positive())
    .parse(value)
  return make<QuantityType>()(v)
}

export const LowStockThreshold = (value: unknown) => {
  const v = z
    .preprocess((v) => (typeof v === 'string' ? Number(v) : v), z.number().int().positive())
    .parse(value)
  return make<LowStockThresholdType>()(v)
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

const purchaseConditions: PurchaseCondition[] = ['new', 'used']

export const parsePurchaseCondition = (value: unknown): PurchaseCondition => {
  const v = z.string().parse(value)
  if (!purchaseConditions.includes(v as PurchaseCondition))
    throw new Error(`Invalid purchase condition: ${v}`)
  return v as PurchaseCondition
}
