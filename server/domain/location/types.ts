import type { Brand } from 'ts-brand'

export type PlaceId = Brand<string, 'PlaceId'>
export type PlaceName = Brand<string, 'PlaceName'>
export type RoomId = Brand<string, 'RoomId'>
export type RoomName = Brand<string, 'RoomName'>
export type ZoneId = Brand<string, 'ZoneId'>
export type ZoneName = Brand<string, 'ZoneName'>
export type StorageId = Brand<string, 'StorageId'>
export type StorageName = Brand<string, 'StorageName'>

export type Place = {
  id: PlaceId
  name: PlaceName
  icon: string | null
  order: number
}

export type Room = {
  id: RoomId
  placeId: PlaceId
  name: RoomName
  icon: string | null
  order: number
}

export type Zone = {
  id: ZoneId
  roomId: RoomId
  name: ZoneName
  order: number
}

export type Storage = {
  id: StorageId
  zoneId: ZoneId
  name: StorageName
  order: number
}
