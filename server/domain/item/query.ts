import { sortBy } from 'lodash-es'
import { match } from 'ts-pattern'
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

export const ItemQuery = { allItems, itemById, itemsByStorage }
