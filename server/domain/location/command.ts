import { randomUUID } from 'node:crypto'
import { emit } from '~/system/event-bus'
import { nextOrder } from './business-rules'
import * as repository from './infrastructure/repository'
import {
  PlaceId,
  PlaceName,
  RoomId,
  RoomName,
  StorageId,
  StorageName,
  ZoneId,
  ZoneName,
} from './primitives'
import type { Place, Room, Storage, Zone } from './types'

// Places

const createPlace = async (input: { name: string; icon?: string | null }) => {
  const existing = await repository.findAllPlaces()
  const place: Place = {
    id: PlaceId(randomUUID()),
    name: PlaceName(input.name),
    icon: input.icon ?? null,
    order: nextOrder(existing),
  }
  await repository.savePlace(place)
  await emit('location-changed', { type: 'place-created' as const, place })
  return place
}

const updatePlace = async (
  id: string,
  input: { name?: string | null; icon?: string | null; order?: number | null },
) => {
  const place = await repository.findPlaceBy(id)
  if (!place) return 'not-found' as const
  const updated: Place = {
    ...place,
    name: input.name ? PlaceName(input.name) : place.name,
    icon: input.icon !== undefined ? (input.icon ?? null) : place.icon,
    order: input.order ?? place.order,
  }
  await repository.savePlace(updated)
  return { tag: 'updated' as const, place: updated }
}

const deletePlace = async (id: string) => {
  const place = await repository.findPlaceBy(id)
  if (!place) return 'not-found' as const
  const rooms = await repository.findRoomsByPlace(id)
  await Promise.all(rooms.map(({ id }) => deleteRoom(id)))
  await repository.removePlace(id)
  await emit('location-changed', { type: 'place-deleted' as const, placeId: id })
  return 'deleted' as const
}

// Rooms

const createRoom = async (input: { placeId: string; name: string; icon?: string | null }) => {
  const place = await repository.findPlaceBy(input.placeId)
  if (!place) return 'place-not-found' as const
  const existing = await repository.findRoomsByPlace(input.placeId)
  const room: Room = {
    id: RoomId(randomUUID()),
    placeId: PlaceId(input.placeId),
    name: RoomName(input.name),
    icon: input.icon ?? null,
    order: nextOrder(existing),
  }
  await repository.saveRoom(room)
  await emit('location-changed', { type: 'room-created' as const, room })
  return { tag: 'created' as const, room }
}

const updateRoom = async (
  id: string,
  input: { name?: string | null; icon?: string | null; order?: number | null },
) => {
  const room = await repository.findRoomBy(id)
  if (!room) return 'not-found' as const
  const updated: Room = {
    ...room,
    name: input.name ? RoomName(input.name) : room.name,
    icon: input.icon !== undefined ? (input.icon ?? null) : room.icon,
    order: input.order ?? room.order,
  }
  await repository.saveRoom(updated)
  return { tag: 'updated' as const, room: updated }
}

const deleteRoom = async (id: string) => {
  const room = await repository.findRoomBy(id)
  if (!room) return 'not-found' as const
  const zones = await repository.findZonesByRoom(id)
  await Promise.all(zones.map(({ id }) => deleteZone(id)))
  await repository.removeRoom(id)
  return 'deleted' as const
}

// Zones

const createZone = async (input: { roomId: string; name: string }) => {
  const room = await repository.findRoomBy(input.roomId)
  if (!room) return 'room-not-found' as const
  const existing = await repository.findZonesByRoom(input.roomId)
  const zone: Zone = {
    id: ZoneId(randomUUID()),
    roomId: RoomId(input.roomId),
    name: ZoneName(input.name),
    order: nextOrder(existing),
  }
  await repository.saveZone(zone)
  await emit('location-changed', { type: 'zone-created' as const, zone })
  return { tag: 'created' as const, zone }
}

const updateZone = async (id: string, input: { name?: string | null; order?: number | null }) => {
  const zone = await repository.findZoneBy(id)
  if (!zone) return 'not-found' as const
  const updated: Zone = {
    ...zone,
    name: input.name ? ZoneName(input.name) : zone.name,
    order: input.order ?? zone.order,
  }
  await repository.saveZone(updated)
  return { tag: 'updated' as const, zone: updated }
}

const deleteZone = async (id: string) => {
  const zone = await repository.findZoneBy(id)
  if (!zone) return 'not-found' as const
  const storages = await repository.findStoragesByZone(id)
  await Promise.all(storages.map(({ id }) => deleteStorage(id)))
  await repository.removeZone(id)
  return 'deleted' as const
}

// Storages

const createStorage = async (input: { zoneId: string; name: string }) => {
  const zone = await repository.findZoneBy(input.zoneId)
  if (!zone) return 'zone-not-found' as const
  const existing = await repository.findStoragesByZone(input.zoneId)
  const storage: Storage = {
    id: StorageId(randomUUID()),
    zoneId: ZoneId(input.zoneId),
    name: StorageName(input.name),
    order: nextOrder(existing),
  }
  await repository.saveStorage(storage)
  await emit('location-changed', { type: 'storage-created' as const, storage })
  return { tag: 'created' as const, storage }
}

const updateStorage = async (
  id: string,
  input: { name?: string | null; order?: number | null },
) => {
  const storage = await repository.findStorageBy(id)
  if (!storage) return 'not-found' as const
  const updated: Storage = {
    ...storage,
    name: input.name ? StorageName(input.name) : storage.name,
    order: input.order ?? storage.order,
  }
  await repository.saveStorage(updated)
  return { tag: 'updated' as const, storage: updated }
}

const deleteStorage = async (id: string) => {
  const storage = await repository.findStorageBy(id)
  if (!storage) return 'not-found' as const
  await repository.removeStorage(id)
  return 'deleted' as const
}

export const LocationCommand = {
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
