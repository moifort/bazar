import { GraphQLError } from 'graphql'
import { ZodError } from 'zod'
import { ImageId } from '~/domain/image/primitives'
import { ItemId, ItemName, Quantity } from '~/domain/item/primitives'
import {
  PlaceId,
  PlaceName,
  RoomId,
  RoomName,
  StorageId,
  StorageName,
  ZoneId,
  ZoneName,
} from '~/domain/location/primitives'
import { ReminderCompletionId, ReminderId, ReminderTitle } from '~/domain/reminder/primitives'
import { UserTag } from '~/domain/shared/primitives'
import { builder } from './builder'

const validatedParse =
  <T>(name: string, parse: (value: unknown) => T) =>
  (value: unknown): T => {
    try {
      return parse(value)
    } catch (error) {
      const message =
        error instanceof ZodError
          ? error.issues.map(({ message }) => message).join(', ')
          : `Invalid ${name}`
      throw new GraphQLError(`Invalid value for ${name}: ${message}`, {
        extensions: { code: 'BAD_USER_INPUT' },
      })
    }
  }

// Item domain
builder.scalarType('ItemId', {
  description: 'Item unique identifier (UUID)',
  serialize: (value) => value as string,
  parseValue: validatedParse('ItemId', ItemId),
})

builder.scalarType('ItemName', {
  description: 'Item name (non-empty, max 500 characters)',
  serialize: (value) => value as string,
  parseValue: validatedParse('ItemName', ItemName),
})

builder.scalarType('Quantity', {
  description: 'Item quantity (positive integer)',
  serialize: (value) => value as number,
  parseValue: validatedParse('Quantity', Quantity),
})

// Location domain
builder.scalarType('PlaceId', {
  description: 'Place unique identifier (UUID)',
  serialize: (value) => value as string,
  parseValue: validatedParse('PlaceId', PlaceId),
})

builder.scalarType('PlaceName', {
  description: 'Place name (non-empty, max 200 characters)',
  serialize: (value) => value as string,
  parseValue: validatedParse('PlaceName', PlaceName),
})

builder.scalarType('RoomId', {
  description: 'Room unique identifier (UUID)',
  serialize: (value) => value as string,
  parseValue: validatedParse('RoomId', RoomId),
})

builder.scalarType('RoomName', {
  description: 'Room name (non-empty, max 200 characters)',
  serialize: (value) => value as string,
  parseValue: validatedParse('RoomName', RoomName),
})

builder.scalarType('ZoneId', {
  description: 'Zone unique identifier (UUID)',
  serialize: (value) => value as string,
  parseValue: validatedParse('ZoneId', ZoneId),
})

builder.scalarType('ZoneName', {
  description: 'Zone name (non-empty, max 200 characters)',
  serialize: (value) => value as string,
  parseValue: validatedParse('ZoneName', ZoneName),
})

builder.scalarType('StorageId', {
  description: 'Storage unique identifier (UUID)',
  serialize: (value) => value as string,
  parseValue: validatedParse('StorageId', StorageId),
})

builder.scalarType('StorageName', {
  description: 'Storage name (non-empty, max 200 characters)',
  serialize: (value) => value as string,
  parseValue: validatedParse('StorageName', StorageName),
})

// Image domain
builder.scalarType('ImageId', {
  description: 'Image unique identifier (UUID)',
  serialize: (value) => value as string,
  parseValue: validatedParse('ImageId', ImageId),
})

// Shared
builder.scalarType('UserTag', {
  description: 'User identifier tag (e.g. "thibaut")',
  serialize: (value) => value as string,
  parseValue: validatedParse('UserTag', UserTag),
})

// Reminder domain
builder.scalarType('ReminderId', {
  description: 'Reminder unique identifier (UUID)',
  serialize: (value) => value as string,
  parseValue: validatedParse('ReminderId', ReminderId),
})

builder.scalarType('ReminderCompletionId', {
  description: 'Reminder completion unique identifier (UUID)',
  serialize: (value) => value as string,
  parseValue: validatedParse('ReminderCompletionId', ReminderCompletionId),
})

builder.scalarType('ReminderTitle', {
  description: 'Reminder title (non-empty, max 200 characters)',
  serialize: (value) => value as string,
  parseValue: validatedParse('ReminderTitle', ReminderTitle),
})
