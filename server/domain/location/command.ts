import { randomUUID } from 'node:crypto'
import type { UserId } from '~/domain/shared/types'
import { emit } from '~/system/event-bus'
import { nextOrder } from './business-rules'
import * as repository from './infrastructure/repository'
import {
  PlaceId as makePlaceId,
  RoomId as makeRoomId,
  StorageId as makeStorageId,
  ZoneId as makeZoneId,
  PlaceName,
  RoomName,
  StorageName,
  ZoneName,
} from './primitives'
import type { Place, PlaceId, Room, RoomId, Storage, StorageId, Zone, ZoneId } from './types'

// Places

const createPlace = async (userId: UserId, input: { name: string; icon?: string | null }) => {
  const existing = await repository.findAllPlaces(userId)
  const place: Place = {
    id: makePlaceId(randomUUID()),
    userId,
    name: PlaceName(input.name),
    icon: input.icon ?? undefined,
    order: nextOrder(existing),
  }
  await repository.savePlace(place)
  await emit('location-changed', { type: 'place-created' as const, place })
  return place
}

const updatePlace = async (
  userId: UserId,
  id: PlaceId,
  input: { name?: string | null; icon?: string | null; order?: number | null },
) => {
  const place = await repository.findPlaceBy(userId, id)
  if (!place) return 'not-found' as const
  const updated: Place = {
    ...place,
    name: input.name ? PlaceName(input.name) : place.name,
    icon: input.icon !== undefined ? (input.icon ?? undefined) : place.icon,
    order: input.order ?? place.order,
  }
  await repository.savePlace(updated)
  return { tag: 'updated' as const, place: updated }
}

const deletePlace = async (userId: UserId, id: PlaceId) => {
  const place = await repository.findPlaceBy(userId, id)
  if (!place) return 'not-found' as const
  const rooms = await repository.findRoomsByPlace(userId, id)
  await Promise.all(rooms.map((r) => deleteRoom(userId, r.id)))
  await repository.removePlace(id)
  await emit('location-changed', { type: 'place-deleted' as const, placeId: id })
  return 'deleted' as const
}

// Rooms

const createRoom = async (
  userId: UserId,
  input: { placeId: PlaceId; name: string; icon?: string | null },
) => {
  const place = await repository.findPlaceBy(userId, input.placeId)
  if (!place) return 'place-not-found' as const
  const existing = await repository.findRoomsByPlace(userId, input.placeId)
  const room: Room = {
    id: makeRoomId(randomUUID()),
    userId,
    placeId: input.placeId,
    name: RoomName(input.name),
    icon: input.icon ?? undefined,
    order: nextOrder(existing),
  }
  await repository.saveRoom(room)
  await emit('location-changed', { type: 'room-created' as const, room })
  return { tag: 'created' as const, room }
}

const updateRoom = async (
  userId: UserId,
  id: RoomId,
  input: { name?: string | null; icon?: string | null; order?: number | null },
) => {
  const room = await repository.findRoomBy(userId, id)
  if (!room) return 'not-found' as const
  const updated: Room = {
    ...room,
    name: input.name ? RoomName(input.name) : room.name,
    icon: input.icon !== undefined ? (input.icon ?? undefined) : room.icon,
    order: input.order ?? room.order,
  }
  await repository.saveRoom(updated)
  return { tag: 'updated' as const, room: updated }
}

const deleteRoom = async (userId: UserId, id: RoomId) => {
  const room = await repository.findRoomBy(userId, id)
  if (!room) return 'not-found' as const
  const zones = await repository.findZonesByRoom(userId, id)
  await Promise.all(zones.map((z) => deleteZone(userId, z.id)))
  await repository.removeRoom(id)
  return 'deleted' as const
}

// Zones

const createZone = async (userId: UserId, input: { roomId: RoomId; name: string }) => {
  const room = await repository.findRoomBy(userId, input.roomId)
  if (!room) return 'room-not-found' as const
  const existing = await repository.findZonesByRoom(userId, input.roomId)
  const zone: Zone = {
    id: makeZoneId(randomUUID()),
    userId,
    roomId: input.roomId,
    name: ZoneName(input.name),
    order: nextOrder(existing),
  }
  await repository.saveZone(zone)
  await emit('location-changed', { type: 'zone-created' as const, zone })
  return { tag: 'created' as const, zone }
}

const updateZone = async (
  userId: UserId,
  id: ZoneId,
  input: { name?: string | null; order?: number | null },
) => {
  const zone = await repository.findZoneBy(userId, id)
  if (!zone) return 'not-found' as const
  const updated: Zone = {
    ...zone,
    name: input.name ? ZoneName(input.name) : zone.name,
    order: input.order ?? zone.order,
  }
  await repository.saveZone(updated)
  return { tag: 'updated' as const, zone: updated }
}

const deleteZone = async (userId: UserId, id: ZoneId) => {
  const zone = await repository.findZoneBy(userId, id)
  if (!zone) return 'not-found' as const
  const storages = await repository.findStoragesByZone(userId, id)
  await Promise.all(storages.map((s) => deleteStorage(userId, s.id)))
  await repository.removeZone(id)
  return 'deleted' as const
}

// Storages

const createStorage = async (userId: UserId, input: { zoneId: ZoneId; name: string }) => {
  const zone = await repository.findZoneBy(userId, input.zoneId)
  if (!zone) return 'zone-not-found' as const
  const existing = await repository.findStoragesByZone(userId, input.zoneId)
  const storage: Storage = {
    id: makeStorageId(randomUUID()),
    userId,
    zoneId: input.zoneId,
    name: StorageName(input.name),
    order: nextOrder(existing),
  }
  await repository.saveStorage(storage)
  await emit('location-changed', { type: 'storage-created' as const, storage })
  return { tag: 'created' as const, storage }
}

const updateStorage = async (
  userId: UserId,
  id: StorageId,
  input: { name?: string | null; order?: number | null },
) => {
  const storage = await repository.findStorageBy(userId, id)
  if (!storage) return 'not-found' as const
  const updated: Storage = {
    ...storage,
    name: input.name ? StorageName(input.name) : storage.name,
    order: input.order ?? storage.order,
  }
  await repository.saveStorage(updated)
  return { tag: 'updated' as const, storage: updated }
}

const deleteStorage = async (userId: UserId, id: StorageId) => {
  const storage = await repository.findStorageBy(userId, id)
  if (!storage) return 'not-found' as const
  await repository.removeStorage(id)
  return 'deleted' as const
}

const forget = (userId: UserId): Promise<void> => repository.removeAllByUser(userId)

export const LocationCommand = {
  forget,
  createPlace,
  updatePlace,
  deletePlace,
  createRoom,
  updateRoom,
  deleteRoom,
  createZone,
  updateZone,
  deleteZone,
  createStorage,
  updateStorage,
  deleteStorage,
}
