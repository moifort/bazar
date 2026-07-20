import { ItemQuery } from '~/domain/item/query'
import { LocationQuery } from '~/domain/location/query'
import type { UserId } from '~/domain/shared/types'
import { searchEntries } from './business-rules'
import type { SearchEntry } from './types'

const entries = async (userId: UserId): Promise<SearchEntry[]> => {
  const [items, places, rooms] = await Promise.all([
    ItemQuery.all(userId),
    LocationQuery.allPlaces(userId),
    LocationQuery.allRooms(userId),
  ])

  return [
    ...items.map((item) => ({
      type: 'item' as const,
      entityId: item.id,
      text: [item.name, item.description, item.personalNotes].filter(Boolean).join(' '),
    })),
    ...places.map((place) => ({
      type: 'place' as const,
      entityId: place.id,
      text: place.name,
    })),
    ...rooms.map((room) => ({
      type: 'room' as const,
      entityId: room.id,
      text: room.name,
    })),
  ]
}

const search = async (userId: UserId, query: string, limit = 20) =>
  searchEntries(await entries(userId), query, limit)

export const SearchQuery = { search }
