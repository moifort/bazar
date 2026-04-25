import type { UserId } from '~/domain/shared/types'
import { fullPath } from './business-rules'
import * as repository from './infrastructure/repository'
import type { Place, PlaceId, Room, RoomId, Storage, StorageId, Zone, ZoneId } from './types'

export type LocationPath = {
  place: Place
  room: Room
  zone: Zone
  storage: Storage
  fullPath: string
}

const allPlaces = (userId: UserId) => repository.findAllPlaces(userId)

const placeById = (userId: UserId, id: PlaceId) => repository.findPlaceBy(userId, id)

const roomsByPlace = (userId: UserId, placeId: PlaceId) =>
  repository.findRoomsByPlace(userId, placeId)

const zonesByRoom = (userId: UserId, roomId: RoomId) => repository.findZonesByRoom(userId, roomId)

const storagesByZone = (userId: UserId, zoneId: ZoneId) =>
  repository.findStoragesByZone(userId, zoneId)

const storageById = (userId: UserId, id: StorageId) => repository.findStorageBy(userId, id)

const resolveLocationPath = async (
  userId: UserId,
  storageId: StorageId,
): Promise<LocationPath | null> => {
  const storage = await repository.findStorageBy(userId, storageId)
  if (!storage) return null

  const zone = await repository.findZoneBy(userId, storage.zoneId)
  if (!zone) return null

  const room = await repository.findRoomBy(userId, zone.roomId)
  if (!room) return null

  const place = await repository.findPlaceBy(userId, room.placeId)
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
