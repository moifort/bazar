import * as itemRepository from '~/domain/item/infrastructure/repository'
import * as locationRepository from '~/domain/location/infrastructure/repository'
import type { UserId } from '~/domain/shared/types'
import type { SearchEntry } from './types'

export const buildEntries = async (userId: UserId): Promise<SearchEntry[]> => {
  const [items, places, rooms] = await Promise.all([
    itemRepository.findAllByUser(userId),
    locationRepository.findAllPlaces(userId),
    locationRepository.findAllRooms(userId),
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
