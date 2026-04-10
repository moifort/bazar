import { builder } from '~/domain/shared/graphql/builder'

export const CreatePlaceInput = builder.inputType('CreatePlaceInput', {
  description: 'Input for creating a new place',
  fields: (t) => ({
    name: t.field({ type: 'PlaceName', required: true, description: 'Place name' }),
    icon: t.string({ description: 'Optional emoji icon' }),
  }),
})

export const UpdatePlaceInput = builder.inputType('UpdatePlaceInput', {
  description: 'Input for updating a place',
  fields: (t) => ({
    name: t.field({ type: 'PlaceName', description: 'New place name' }),
    icon: t.string({ description: 'New emoji icon' }),
    order: t.int({ description: 'New sort order' }),
  }),
})

export const CreateRoomInput = builder.inputType('CreateRoomInput', {
  description: 'Input for creating a new room',
  fields: (t) => ({
    placeId: t.field({ type: 'PlaceId', required: true, description: 'Parent place' }),
    name: t.field({ type: 'RoomName', required: true, description: 'Room name' }),
    icon: t.string({ description: 'Optional emoji icon' }),
  }),
})

export const UpdateRoomInput = builder.inputType('UpdateRoomInput', {
  description: 'Input for updating a room',
  fields: (t) => ({
    name: t.field({ type: 'RoomName', description: 'New room name' }),
    icon: t.string({ description: 'New emoji icon' }),
    order: t.int({ description: 'New sort order' }),
  }),
})

export const CreateZoneInput = builder.inputType('CreateZoneInput', {
  description: 'Input for creating a new zone',
  fields: (t) => ({
    roomId: t.field({ type: 'RoomId', required: true, description: 'Parent room' }),
    name: t.field({ type: 'ZoneName', required: true, description: 'Zone name' }),
  }),
})

export const UpdateZoneInput = builder.inputType('UpdateZoneInput', {
  description: 'Input for updating a zone',
  fields: (t) => ({
    name: t.field({ type: 'ZoneName', description: 'New zone name' }),
    order: t.int({ description: 'New sort order' }),
  }),
})

export const CreateStorageInput = builder.inputType('CreateStorageInput', {
  description: 'Input for creating a new storage spot',
  fields: (t) => ({
    zoneId: t.field({ type: 'ZoneId', required: true, description: 'Parent zone' }),
    name: t.field({ type: 'StorageName', required: true, description: 'Storage name' }),
  }),
})

export const UpdateStorageInput = builder.inputType('UpdateStorageInput', {
  description: 'Input for updating a storage spot',
  fields: (t) => ({
    name: t.field({ type: 'StorageName', description: 'New storage name' }),
    order: t.int({ description: 'New sort order' }),
  }),
})
