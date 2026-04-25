import DataLoader from 'dataloader'
import { keyBy } from 'lodash-es'
import * as locationRepository from '~/domain/location/infrastructure/repository'
import type { Place, Room, Storage, Zone } from '~/domain/location/types'
import type { UserId } from '~/domain/shared/types'

export const createLoaders = (userId: UserId) => ({
  place: new DataLoader<string, Place | null>(async (placeIds) => {
    const places = await locationRepository.findAllPlaces(userId)
    const byId = keyBy(places, ({ id }) => id)
    return placeIds.map((id) => byId[id] ?? null)
  }),

  room: new DataLoader<string, Room | null>(async (roomIds) => {
    const rooms = await locationRepository.findAllRooms(userId)
    const byId = keyBy(rooms, ({ id }) => id)
    return roomIds.map((id) => byId[id] ?? null)
  }),

  zone: new DataLoader<string, Zone | null>(async (zoneIds) => {
    const zones = await locationRepository.findAllZones(userId)
    const byId = keyBy(zones, ({ id }) => id)
    return zoneIds.map((id) => byId[id] ?? null)
  }),

  storage: new DataLoader<string, Storage | null>(async (storageIds) => {
    const storages = await locationRepository.findAllStorages(userId)
    const byId = keyBy(storages, ({ id }) => id)
    return storageIds.map((id) => byId[id] ?? null)
  }),
})

export type Loaders = ReturnType<typeof createLoaders>
