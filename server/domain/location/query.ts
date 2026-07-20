import type { UserId } from '~/domain/shared/types'
import { fullPath } from './business-rules'
import * as repository from './infrastructure/repository'
import type { Place, PlaceId, Room, RoomId, Storage, StorageId, Zone, ZoneId } from './types'

export type LocationPath = {
  place: Place
  room: Room
  zone: Zone
  storage?: Storage
  fullPath: string
}

const allPlaces = (userId: UserId) => repository.findAllPlaces(userId)

const allRooms = (userId: UserId) => repository.findAllRooms(userId)

const allZones = (userId: UserId) => repository.findAllZones(userId)

const allStorages = (userId: UserId) => repository.findAllStorages(userId)

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
): Promise<LocationPath | undefined> => {
  const storage = await repository.findStorageBy(userId, storageId)
  if (!storage) return undefined

  const zone = await repository.findZoneBy(userId, storage.zoneId)
  if (!zone) return undefined

  const room = await repository.findRoomBy(userId, zone.roomId)
  if (!room) return undefined

  const place = await repository.findPlaceBy(userId, room.placeId)
  if (!place) return undefined

  return {
    place,
    room,
    zone,
    storage,
    fullPath: fullPath(place, room, zone, storage),
  }
}

const resolveZoneLocationPath = async (
  userId: UserId,
  zoneId: ZoneId,
): Promise<LocationPath | undefined> => {
  const zone = await repository.findZoneBy(userId, zoneId)
  if (!zone) return undefined

  const room = await repository.findRoomBy(userId, zone.roomId)
  if (!room) return undefined

  const place = await repository.findPlaceBy(userId, room.placeId)
  if (!place) return undefined

  return {
    place,
    room,
    zone,
    storage: undefined,
    fullPath: fullPath(place, room, zone),
  }
}

export const LocationQuery = {
  allPlaces,
  allRooms,
  allZones,
  allStorages,
  placeById,
  roomsByPlace,
  zonesByRoom,
  storagesByZone,
  storageById,
  resolveLocationPath,
  resolveZoneLocationPath,
}
