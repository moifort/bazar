import { fullPath } from './business-rules'
import * as repository from './infrastructure/repository'
import type { Place, PlaceId, Room, Storage, StorageId, Zone } from './types'

export type LocationPath = {
  place: Place
  room: Room
  zone: Zone
  storage: Storage
  fullPath: string
}

const allPlaces = () => repository.findAllPlaces()

const placeById = (id: PlaceId) => repository.findPlaceBy(id)

const roomsByPlace = (placeId: PlaceId) => repository.findRoomsByPlace(placeId)

const zonesByRoom = (roomId: string) => repository.findZonesByRoom(roomId)

const storagesByZone = (zoneId: string) => repository.findStoragesByZone(zoneId)

const storageById = (id: StorageId) => repository.findStorageBy(id)

const resolveLocationPath = async (storageId: StorageId): Promise<LocationPath | null> => {
  const storage = await repository.findStorageBy(storageId)
  if (!storage) return null

  const zone = await repository.findZoneBy(storage.zoneId)
  if (!zone) return null

  const room = await repository.findRoomBy(zone.roomId)
  if (!room) return null

  const place = await repository.findPlaceBy(room.placeId)
  if (!place) return null

  return {
    place,
    room,
    zone,
    storage,
    fullPath: fullPath(place, room, zone, storage),
  }
}

export const LocationQuery = {
  allPlaces,
  placeById,
  roomsByPlace,
  zonesByRoom,
  storagesByZone,
  storageById,
  resolveLocationPath,
}
