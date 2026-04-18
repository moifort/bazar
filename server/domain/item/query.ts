import { sortBy } from 'lodash-es'
import { match } from 'ts-pattern'
import { LocationQuery } from '~/domain/location/query'
import type { ZoneId } from '~/domain/location/types'
import * as repository from './infrastructure/repository'
import type { ItemCategory, ItemId, ItemSort } from './types'

type SortOrder = 'asc' | 'desc'

type ItemFilters = {
  category?: ItemCategory | null
  placeId?: string | null
  roomId?: string | null
  search?: string | null
  sort?: ItemSort | null
  order?: SortOrder | null
  offset?: number | null
  limit?: number | null
}

const allItems = async (filters: ItemFilters = {}) => {
  let items = await repository.findAll()

  if (filters.category) {
    items = items.filter((item) => item.category === filters.category)
  }

  if (filters.placeId) {
    items = items.filter((item) => item.placeId === filters.placeId)
  }

  if (filters.search) {
    const query = filters.search.toLowerCase()
    items = items.filter(
      (item) =>
        item.name.toLowerCase().includes(query) ||
        item.description.toLowerCase().includes(query) ||
        item.personalNotes.toLowerCase().includes(query),
    )
  }

  const totalCount = items.length

  const sortField = filters.sort ?? 'created-at'
  const sorted = match(sortField)
    .with('name', () => sortBy(items, ({ name }) => name.toLowerCase()))
    .with('category', () => sortBy(items, ({ category }) => category))
    .with('created-at', () => sortBy(items, ({ createdAt }) => createdAt).reverse())
    .with('updated-at', () => sortBy(items, ({ updatedAt }) => updatedAt).reverse())
    .exhaustive()

  const ordered =
    filters.order === 'asc' && (sortField === 'created-at' || sortField === 'updated-at')
      ? sorted.reverse()
      : filters.order === 'desc' && sortField !== 'created-at' && sortField !== 'updated-at'
        ? sorted.reverse()
        : sorted

  const offset = filters.offset ?? 0
  const limit = filters.limit ?? 40
  const paged = ordered.slice(offset, offset + limit)

  return {
    items: paged,
    totalCount,
    hasMore: offset + limit < totalCount,
  }
}

const itemById = (id: ItemId) => repository.findBy(id)

const itemsByStorage = async (storageId: string) => {
  const all = await repository.findAll()
  return all.filter((item) => item.storageId === storageId)
}

const distinctPurchaseLocations = async (): Promise<string[]> => {
  const all = await repository.findAll()
  const counts = new Map<string, number>()
  for (const { purchaseLocation } of all) {
    const value = purchaseLocation.trim()
    if (!value) continue
    counts.set(value, (counts.get(value) ?? 0) + 1)
  }
  return [...counts.entries()]
    .sort(([a, ca], [b, cb]) => cb - ca || a.localeCompare(b, undefined, { sensitivity: 'base' }))
    .map(([value]) => value)
}

const countByZone = async (zoneId: ZoneId): Promise<number> => {
  const storages = await LocationQuery.storagesByZone(zoneId)
  if (storages.length === 0) return 0
  const storageIds = new Set<string>(storages.map(({ id }) => id))
  const items = await repository.findAll()
  return items.reduce(
    (count, { storageId }) => (storageId !== null && storageIds.has(storageId) ? count + 1 : count),
    0,
  )
}

export const ItemQuery = {
  allItems,
  itemById,
  itemsByStorage,
  distinctPurchaseLocations,
  countByZone,
}
