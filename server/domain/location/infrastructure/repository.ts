import { sortBy } from 'lodash-es'
import { createTypedStorage } from '~/system/storage'
import type { Place, Room, Storage, Zone } from '../types'

const placesStorage = () => createTypedStorage<Place>('places')
const roomsStorage = () => createTypedStorage<Room>('rooms')
const zonesStorage = () => createTypedStorage<Zone>('zones')
const storagesStorage = () => createTypedStorage<Storage>('storages')

// Places

export const findAllPlaces = async () => {
  const keys = await placesStorage().getKeys()
  const items = await placesStorage().getItems(keys)
  return sortBy(
    items.map(({ value }) => value),
    ({ order }) => order,
  )
}

export const findPlaceBy = (id: string) => placesStorage().getItem(id)

export const savePlace = (place: Place) => placesStorage().setItem(place.id, place)

export const removePlace = (id: string) => placesStorage().removeItem(id)

// Rooms

export const findAllRooms = async () => {
  const keys = await roomsStorage().getKeys()
  const items = await roomsStorage().getItems(keys)
  return sortBy(
    items.map(({ value }) => value),
    ({ order }) => order,
  )
}

export const findRoomBy = (id: string) => roomsStorage().getItem(id)

export const findRoomsByPlace = async (placeId: string) => {
  const all = await findAllRooms()
  return all.filter((room) => room.placeId === placeId)
}

export const saveRoom = (room: Room) => roomsStorage().setItem(room.id, room)

export const removeRoom = (id: string) => roomsStorage().removeItem(id)

// Zones

export const findAllZones = async () => {
  const keys = await zonesStorage().getKeys()
  const items = await zonesStorage().getItems(keys)
  return sortBy(
    items.map(({ value }) => value),
    ({ order }) => order,
  )
}

export const findZoneBy = (id: string) => zonesStorage().getItem(id)

export const findZonesByRoom = async (roomId: string) => {
  const all = await findAllZones()
  return all.filter((zone) => zone.roomId === roomId)
}

export const saveZone = (zone: Zone) => zonesStorage().setItem(zone.id, zone)

export const removeZone = (id: string) => zonesStorage().removeItem(id)

// Storages

export const findAllStorages = async () => {
  const keys = await storagesStorage().getKeys()
  const items = await storagesStorage().getItems(keys)
  return sortBy(
    items.map(({ value }) => value),
    ({ order }) => order,
  )
}

export const findStorageBy = (id: string) => storagesStorage().getItem(id)

export const findStoragesByZone = async (zoneId: string) => {
  const all = await findAllStorages()
  return all.filter((storage) => storage.zoneId === zoneId)
}

export const saveStorage = (storage: Storage) => storagesStorage().setItem(storage.id, storage)

export const removeStorage = (id: string) => storagesStorage().removeItem(id)
