import type { UserId } from '~/domain/shared/types'
import { db } from '~/system/firebase'
import { genericDataConverter } from '~/utils/firestore'
import type { Place, PlaceId, Room, RoomId, Storage, StorageId, Zone, ZoneId } from '../types'

const places = () => db().collection('places').withConverter(genericDataConverter<Place>())
const rooms = () => db().collection('rooms').withConverter(genericDataConverter<Room>())
const zones = () => db().collection('zones').withConverter(genericDataConverter<Zone>())
const storages = () => db().collection('storages').withConverter(genericDataConverter<Storage>())

const ownedDoc = async <T extends { userId: UserId }>(
  ref: FirebaseFirestore.DocumentReference<T>,
  userId: UserId,
): Promise<T | null> => {
  const snap = await ref.get()
  const data = snap.data()
  return data && data.userId === userId ? data : null
}

// Places

export const findAllPlaces = async (userId: UserId): Promise<Place[]> => {
  const snap = await places().where('userId', '==', userId).orderBy('order').get()
  return snap.docs.map((doc) => doc.data())
}

export const findPlaceBy = (userId: UserId, id: PlaceId) => ownedDoc(places().doc(id), userId)

export const savePlace = async (place: Place) => {
  await places().doc(place.id).set(place)
  return place
}

export const removePlace = async (id: PlaceId) => {
  await places().doc(id).delete()
}

// Rooms

export const findAllRooms = async (userId: UserId): Promise<Room[]> => {
  const snap = await rooms().where('userId', '==', userId).orderBy('order').get()
  return snap.docs.map((doc) => doc.data())
}

export const findRoomBy = (userId: UserId, id: RoomId) => ownedDoc(rooms().doc(id), userId)

export const findRoomsByPlace = async (userId: UserId, placeId: PlaceId): Promise<Room[]> => {
  const snap = await rooms()
    .where('userId', '==', userId)
    .where('placeId', '==', placeId)
    .orderBy('order')
    .get()
  return snap.docs.map((doc) => doc.data())
}

export const saveRoom = async (room: Room) => {
  await rooms().doc(room.id).set(room)
  return room
}

export const removeRoom = async (id: RoomId) => {
  await rooms().doc(id).delete()
}

// Zones

export const findAllZones = async (userId: UserId): Promise<Zone[]> => {
  const snap = await zones().where('userId', '==', userId).orderBy('order').get()
  return snap.docs.map((doc) => doc.data())
}

export const findZoneBy = (userId: UserId, id: ZoneId) => ownedDoc(zones().doc(id), userId)

export const findZonesByRoom = async (userId: UserId, roomId: RoomId): Promise<Zone[]> => {
  const snap = await zones()
    .where('userId', '==', userId)
    .where('roomId', '==', roomId)
    .orderBy('order')
    .get()
  return snap.docs.map((doc) => doc.data())
}

export const saveZone = async (zone: Zone) => {
  await zones().doc(zone.id).set(zone)
  return zone
}

export const removeZone = async (id: ZoneId) => {
  await zones().doc(id).delete()
}

// Storages

export const findAllStorages = async (userId: UserId): Promise<Storage[]> => {
  const snap = await storages().where('userId', '==', userId).orderBy('order').get()
  return snap.docs.map((doc) => doc.data())
}

export const findStorageBy = (userId: UserId, id: StorageId) => ownedDoc(storages().doc(id), userId)

export const findStoragesByZone = async (userId: UserId, zoneId: ZoneId): Promise<Storage[]> => {
  const snap = await storages()
    .where('userId', '==', userId)
    .where('zoneId', '==', zoneId)
    .orderBy('order')
    .get()
  return snap.docs.map((doc) => doc.data())
}

export const saveStorage = async (storage: Storage) => {
  await storages().doc(storage.id).set(storage)
  return storage
}

export const removeStorage = async (id: StorageId) => {
  await storages().doc(id).delete()
}
