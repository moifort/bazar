import type { LocationPath } from '~/domain/location/query'
import { LocationQuery } from '~/domain/location/query'
import { builder } from '~/domain/shared/graphql/builder'
import type { Item } from '../../types'
import { ItemCategoryEnum } from './enums'

const LocationPathType = builder.objectRef<LocationPath>('LocationPath').implement({
  description: 'Full resolved location path for an item',
  fields: (t) => ({
    fullPath: t.exposeString('fullPath', {
      description: 'Full path string (e.g. "Appartement > Cuisine > Placard > Etagere 2")',
    }),
    placeId: t.field({ type: 'PlaceId', resolve: (path) => path.place.id }),
    placeName: t.field({ type: 'PlaceName', resolve: (path) => path.place.name }),
    roomId: t.field({ type: 'RoomId', resolve: (path) => path.room.id }),
    roomName: t.field({ type: 'RoomName', resolve: (path) => path.room.name }),
    zoneId: t.field({ type: 'ZoneId', resolve: (path) => path.zone.id }),
    zoneName: t.field({ type: 'ZoneName', resolve: (path) => path.zone.name }),
    storageId: t.field({ type: 'StorageId', resolve: (path) => path.storage.id }),
    storageName: t.field({ type: 'StorageName', resolve: (path) => path.storage.name }),
  }),
})

export const ItemType = builder.objectRef<Item>('Item').implement({
  description: 'A household item stored in the inventory',
  fields: (t) => ({
    id: t.expose('id', { type: 'ItemId', description: 'Item unique identifier' }),
    name: t.expose('name', { type: 'ItemName', description: 'Item display name' }),
    description: t.exposeString('description', { description: 'Item description' }),
    category: t.expose('category', { type: ItemCategoryEnum, description: 'Item category' }),
    quantity: t.expose('quantity', { type: 'Quantity', description: 'Number of identical items' }),
    photoImageId: t.expose('photoImageId', {
      type: 'ImageId',
      nullable: true,
      description: 'Photo image identifier',
    }),
    addedBy: t.expose('addedBy', { type: 'UserTag', description: 'User who added this item' }),
    personalNotes: t.exposeString('personalNotes', { description: 'Personal notes' }),
    createdAt: t.expose('createdAt', { type: 'DateTime', description: 'Creation date' }),
    updatedAt: t.expose('updatedAt', { type: 'DateTime', description: 'Last update date' }),
    location: t.field({
      type: LocationPathType,
      nullable: true,
      description: 'Resolved location path',
      resolve: (item) =>
        item.storageId ? LocationQuery.resolveLocationPath(item.storageId) : null,
    }),
  }),
})

export const ItemsType = builder
  .objectRef<{ items: Item[]; totalCount: number; hasMore: boolean }>('Items')
  .implement({
    description: 'Paginated list of items',
    fields: (t) => ({
      items: t.field({ type: [ItemType], resolve: (data) => data.items }),
      totalCount: t.exposeInt('totalCount', { description: 'Total number of matching items' }),
      hasMore: t.exposeBoolean('hasMore', { description: 'Whether more items are available' }),
    }),
  })
