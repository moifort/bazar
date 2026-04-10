import * as itemRepository from '~/domain/item/infrastructure/repository'
import * as locationRepository from '~/domain/location/infrastructure/repository'
import { createLogger } from '~/system/logger'
import type { SearchEntry } from './types'

const log = createLogger('search-index')

let entries: SearchEntry[] = []

export const getEntries = () => entries

export const rebuildIndex = async () => {
  const items = await itemRepository.findAll()
  const places = await locationRepository.findAllPlaces()
  const rooms = await locationRepository.findAllRooms()

  entries = [
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

  log.info(`Search index rebuilt with ${entries.length} entries`)
}
