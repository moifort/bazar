import type { Brand } from 'ts-brand'
import type { UserId } from '~/domain/shared/types'

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
  userId: UserId
  name: PlaceName
  icon?: string
  order: number
}

export type Room = {
  id: RoomId
  userId: UserId
  placeId: PlaceId
  name: RoomName
  icon?: string
  order: number
}

export type Zone = {
  id: ZoneId
  userId: UserId
  roomId: RoomId
  name: ZoneName
  order: number
}

export type Storage = {
  id: StorageId
  userId: UserId
  zoneId: ZoneId
  name: StorageName
  order: number
}
