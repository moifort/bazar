import { GraphQLError } from 'graphql'
import { builder } from '~/domain/shared/graphql/builder'
import { LocationCommand } from '../../command'
import {
  CreatePlaceInput,
  CreateRoomInput,
  CreateStorageInput,
  CreateZoneInput,
  UpdatePlaceInput,
  UpdateRoomInput,
  UpdateStorageInput,
  UpdateZoneInput,
} from './inputs'
import { PlaceType, RoomType, StorageType, ZoneType } from './types'

// Places

builder.mutationField('createPlace', (t) =>
  t.field({
    type: PlaceType,
    description: 'Create a new place (e.g. Appartement, Cave)',
    args: { input: t.arg({ type: CreatePlaceInput, required: true }) },
    resolve: (_root, { input }) => LocationCommand.createPlace(input),
  }),
)

builder.mutationField('updatePlace', (t) =>
  t.field({
    type: PlaceType,
    description: 'Update an existing place',
    args: {
      id: t.arg({ type: 'PlaceId', required: true }),
      input: t.arg({ type: UpdatePlaceInput, required: true }),
    },
    resolve: async (_root, { id, input }) => {
      const result = await LocationCommand.updatePlace(id, input)
      if (result === 'not-found')
        throw new GraphQLError('Place not found', { extensions: { code: 'NOT_FOUND' } })
      return result.place
    },
  }),
)

builder.mutationField('deletePlace', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Delete a place and all its rooms, zones, and storages',
    args: { id: t.arg({ type: 'PlaceId', required: true }) },
    resolve: async (_root, { id }) => {
      const result = await LocationCommand.deletePlace(id)
      if (result === 'not-found')
        throw new GraphQLError('Place not found', { extensions: { code: 'NOT_FOUND' } })
      return true
    },
  }),
)

// Rooms

builder.mutationField('createRoom', (t) =>
  t.field({
    type: RoomType,
    description: 'Create a new room in a place',
    args: { input: t.arg({ type: CreateRoomInput, required: true }) },
    resolve: async (_root, { input }) => {
      const result = await LocationCommand.createRoom(input)
      if (result === 'place-not-found')
        throw new GraphQLError('Place not found', { extensions: { code: 'NOT_FOUND' } })
      return result.room
    },
  }),
)

builder.mutationField('updateRoom', (t) =>
  t.field({
    type: RoomType,
    description: 'Update an existing room',
    args: {
      id: t.arg({ type: 'RoomId', required: true }),
      input: t.arg({ type: UpdateRoomInput, required: true }),
    },
    resolve: async (_root, { id, input }) => {
      const result = await LocationCommand.updateRoom(id, input)
      if (result === 'not-found')
        throw new GraphQLError('Room not found', { extensions: { code: 'NOT_FOUND' } })
      return result.room
    },
  }),
)

builder.mutationField('deleteRoom', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Delete a room and all its zones and storages',
    args: { id: t.arg({ type: 'RoomId', required: true }) },
    resolve: async (_root, { id }) => {
      const result = await LocationCommand.deleteRoom(id)
      if (result === 'not-found')
        throw new GraphQLError('Room not found', { extensions: { code: 'NOT_FOUND' } })
      return true
    },
  }),
)

// Zones

builder.mutationField('createZone', (t) =>
  t.field({
    type: ZoneType,
    description: 'Create a new zone in a room',
    args: { input: t.arg({ type: CreateZoneInput, required: true }) },
    resolve: async (_root, { input }) => {
      const result = await LocationCommand.createZone(input)
      if (result === 'room-not-found')
        throw new GraphQLError('Room not found', { extensions: { code: 'NOT_FOUND' } })
      return result.zone
    },
  }),
)

builder.mutationField('updateZone', (t) =>
  t.field({
    type: ZoneType,
    description: 'Update an existing zone',
    args: {
      id: t.arg({ type: 'ZoneId', required: true }),
      input: t.arg({ type: UpdateZoneInput, required: true }),
    },
    resolve: async (_root, { id, input }) => {
      const result = await LocationCommand.updateZone(id, input)
      if (result === 'not-found')
        throw new GraphQLError('Zone not found', { extensions: { code: 'NOT_FOUND' } })
      return result.zone
    },
  }),
)

builder.mutationField('deleteZone', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Delete a zone and all its storages',
    args: { id: t.arg({ type: 'ZoneId', required: true }) },
    resolve: async (_root, { id }) => {
      const result = await LocationCommand.deleteZone(id)
      if (result === 'not-found')
        throw new GraphQLError('Zone not found', { extensions: { code: 'NOT_FOUND' } })
      return true
    },
  }),
)

// Storages

builder.mutationField('createStorage', (t) =>
  t.field({
    type: StorageType,
    description: 'Create a new storage spot in a zone',
    args: { input: t.arg({ type: CreateStorageInput, required: true }) },
    resolve: async (_root, { input }) => {
      const result = await LocationCommand.createStorage(input)
      if (result === 'zone-not-found')
        throw new GraphQLError('Zone not found', { extensions: { code: 'NOT_FOUND' } })
      return result.storage
    },
  }),
)

builder.mutationField('updateStorage', (t) =>
  t.field({
    type: StorageType,
    description: 'Update an existing storage spot',
    args: {
      id: t.arg({ type: 'StorageId', required: true }),
      input: t.arg({ type: UpdateStorageInput, required: true }),
    },
    resolve: async (_root, { id, input }) => {
      const result = await LocationCommand.updateStorage(id, input)
      if (result === 'not-found')
        throw new GraphQLError('Storage not found', { extensions: { code: 'NOT_FOUND' } })
      return result.storage
    },
  }),
)

builder.mutationField('deleteStorage', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Delete a storage spot',
    args: { id: t.arg({ type: 'StorageId', required: true }) },
    resolve: async (_root, { id }) => {
      const result = await LocationCommand.deleteStorage(id)
      if (result === 'not-found')
        throw new GraphQLError('Storage not found', { extensions: { code: 'NOT_FOUND' } })
      return true
    },
  }),
)
