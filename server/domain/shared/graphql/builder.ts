import SchemaBuilder from '@pothos/core'
import { GraphQLScalarType } from 'graphql'
import type { H3Event } from 'h3'
import type { ImageId } from '~/domain/image/types'
import type { ItemId, ItemName, Quantity } from '~/domain/item/types'
import type {
  PlaceId,
  PlaceName,
  RoomId,
  RoomName,
  StorageId,
  StorageName,
  ZoneId,
  ZoneName,
} from '~/domain/location/types'
import type { UserTag } from '~/domain/shared/types'
import type { Loaders } from './loaders'

export type GraphQLContext = {
  event: H3Event
  loaders: Loaders
  userTag: string
}

const DateTimeScalar = new GraphQLScalarType({
  name: 'DateTime',
  description: 'ISO 8601 date-time string',
  serialize: (value: unknown) => (value instanceof Date ? value.toISOString() : value),
  parseValue: (value: unknown) => new Date(value as string),
})

export const builder = new SchemaBuilder<{
  Context: GraphQLContext
  DefaultFieldNullability: false
  Scalars: {
    DateTime: { Input: Date; Output: Date }
    ItemId: { Input: ItemId; Output: ItemId }
    ItemName: { Input: ItemName; Output: ItemName }
    Quantity: { Input: Quantity; Output: Quantity }
    PlaceId: { Input: PlaceId; Output: PlaceId }
    PlaceName: { Input: PlaceName; Output: PlaceName }
    RoomId: { Input: RoomId; Output: RoomId }
    RoomName: { Input: RoomName; Output: RoomName }
    ZoneId: { Input: ZoneId; Output: ZoneId }
    ZoneName: { Input: ZoneName; Output: ZoneName }
    StorageId: { Input: StorageId; Output: StorageId }
    StorageName: { Input: StorageName; Output: StorageName }
    ImageId: { Input: ImageId; Output: ImageId }
    UserTag: { Input: UserTag; Output: UserTag }
  }
}>({
  defaultFieldNullability: false,
})

builder.addScalarType('DateTime', DateTimeScalar)
builder.queryType({})
builder.mutationType({})
