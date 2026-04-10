import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  PlaceId as PlaceIdType,
  PlaceName as PlaceNameType,
  RoomId as RoomIdType,
  RoomName as RoomNameType,
  StorageId as StorageIdType,
  StorageName as StorageNameType,
  ZoneId as ZoneIdType,
  ZoneName as ZoneNameType,
} from '~/domain/location/types'

export const PlaceId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<PlaceIdType>()(v)
}

export const PlaceName = (value: unknown) => {
  const v = z.string().min(1).max(200).parse(value)
  return make<PlaceNameType>()(v)
}

export const RoomId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<RoomIdType>()(v)
}

export const RoomName = (value: unknown) => {
  const v = z.string().min(1).max(200).parse(value)
  return make<RoomNameType>()(v)
}

export const ZoneId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<ZoneIdType>()(v)
}

export const ZoneName = (value: unknown) => {
  const v = z.string().min(1).max(200).parse(value)
  return make<ZoneNameType>()(v)
}

export const StorageId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<StorageIdType>()(v)
}

export const StorageName = (value: unknown) => {
  const v = z.string().min(1).max(200).parse(value)
  return make<StorageNameType>()(v)
}
