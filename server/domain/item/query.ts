import { sortBy } from 'lodash-es'
import { match } from 'ts-pattern'
import { LocationQuery } from '~/domain/location/query'
import type { PlaceId, RoomId, ZoneId } from '~/domain/location/types'
import type { UserId } from '~/domain/shared/types'
import * as repository from './infrastructure/repository'
import type { Item, ItemCategory, ItemId, ItemSort } from './types'

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

const all = (userId: UserId) => repository.findAllByUser(userId)

const DEFAULT_LIMIT = 40

const matchesSearch = (item: Item, search: string) => {
  const query = search.toLowerCase()
  return (
    item.name.toLowerCase().includes(query) ||
    item.description.toLowerCase().includes(query) ||
    item.personalNotes.toLowerCase().includes(query)
  )
}

// `search` and `roomId` have no Firestore equivalent: one is full-text, the
// other tests membership of a room's zones and storages, which `in` caps at 30
// values. Both must narrow the set *before* the page is cut, so they force a
// full read — pushing them after Firestore's limit would return short pages.
// Every other combination is filtered, ordered and sliced by Firestore.
const needsFullScan = (filters: ItemFilters) => Boolean(filters.search || filters.roomId)

// An item sits in a room either through one of its zones directly, or through a
// storage inside one of them — both attachments have to be collected.
const attachmentsOfRoom = async (userId: UserId, roomId: RoomId) => {
  const zones = await LocationQuery.zonesByRoom(userId, roomId)
  const storages = await Promise.all(
    zones.map(({ id }) => LocationQuery.storagesByZone(userId, id)),
  )
  return {
    zoneIds: new Set<string>(zones.map(({ id }) => id)),
    storageIds: new Set<string>(storages.flat().map(({ id }) => id)),
  }
}

const allItems = async (userId: UserId, filters: ItemFilters = {}) => {
  const offset = filters.offset ?? 0
  const limit = filters.limit ?? DEFAULT_LIMIT
  const sort = filters.sort ?? 'created-at'

  if (!needsFullScan(filters)) {
    return repository.findPage(userId, {
      category: filters.category ?? undefined,
      placeId: (filters.placeId ?? undefined) as PlaceId | undefined,
      sort,
      order: filters.order ?? undefined,
      offset,
      limit,
    })
  }

  let items = await repository.findAllByUser(userId)

  if (filters.category) items = items.filter((item) => item.category === filters.category)
  if (filters.placeId) items = items.filter((item) => item.placeId === filters.placeId)
  if (filters.search) items = items.filter((item) => matchesSearch(item, filters.search as string))
  if (filters.roomId) {
    const { zoneIds, storageIds } = await attachmentsOfRoom(userId, filters.roomId as RoomId)
    items = items.filter(
      ({ zoneId, storageId }) =>
        (zoneId !== null && zoneIds.has(zoneId)) ||
        (storageId !== null && storageIds.has(storageId)),
    )
  }

  const totalCount = items.length

  const sorted = match(sort)
    .with('name', () => sortBy(items, ({ name }) => name.toLowerCase()))
    .with('category', () => sortBy(items, ({ category }) => category))
    .with('created-at', () => sortBy(items, ({ createdAt }) => createdAt).reverse())
    .with('updated-at', () => sortBy(items, ({ updatedAt }) => updatedAt).reverse())
    .exhaustive()

  const ordered =
    filters.order === 'asc' && (sort === 'created-at' || sort === 'updated-at')
      ? sorted.reverse()
      : filters.order === 'desc' && sort !== 'created-at' && sort !== 'updated-at'
        ? sorted.reverse()
        : sorted

  return {
    items: ordered.slice(offset, offset + limit),
    totalCount,
    hasMore: offset + limit < totalCount,
  }
}

const itemById = (userId: UserId, id: ItemId) => repository.findBy(userId, id)

const itemsByStorage = async (userId: UserId, storageId: string) => {
  const all = await repository.findAllByUser(userId)
  return all.filter((item) => item.storageId === storageId)
}

const distinctPurchaseLocations = async (userId: UserId): Promise<string[]> => {
  const all = await repository.findAllByUser(userId)
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

const countByZone = async (userId: UserId, zoneId: ZoneId): Promise<number> => {
  const storages = await LocationQuery.storagesByZone(userId, zoneId)
  if (storages.length === 0) return 0
  const storageIds = new Set<string>(storages.map(({ id }) => id))
  const items = await repository.findAllByUser(userId)
  return items.reduce(
    (count, { storageId }) => (storageId !== null && storageIds.has(storageId) ? count + 1 : count),
    0,
  )
}

export const ItemQuery = {
  all,
  allItems,
  itemById,
  itemsByStorage,
  distinctPurchaseLocations,
  countByZone,
}
