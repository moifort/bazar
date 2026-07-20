import type { LocationPath } from '~/domain/location/query'
import { ReminderType } from '~/domain/reminder/infrastructure/graphql/types'
import { ReminderQuery } from '~/domain/reminder/query'
import { builder } from '~/domain/shared/graphql/builder'
import type { Item } from '../../types'
import { ItemCategoryEnum, PurchaseConditionEnum } from './enums'

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
    storageId: t.field({
      type: 'StorageId',
      nullable: true,
      resolve: (path) => path.storage?.id ?? null,
    }),
    storageName: t.field({
      type: 'StorageName',
      nullable: true,
      resolve: (path) => path.storage?.name ?? null,
    }),
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
    addedBy: t.expose('addedBy', { type: 'UserId', description: 'User who added this item' }),
    personalNotes: t.exposeString('personalNotes', { description: 'Personal notes' }),
    purchaseDate: t.expose('purchaseDate', {
      type: 'DateTime',
      nullable: true,
      description: 'Date this item was purchased',
    }),
    purchaseLocation: t.exposeString('purchaseLocation', {
      description: 'Where the item was purchased (e.g. "Amazon", "Leroy Merlin")',
    }),
    purchaseCondition: t.field({
      type: PurchaseConditionEnum,
      nullable: true,
      description: 'Whether the item was bought new or used',
      resolve: (item) => item.purchaseCondition,
    }),
    lowStockThreshold: t.exposeInt('lowStockThreshold', {
      nullable: true,
      description: 'Quantity threshold below which a low-stock notification fires',
    }),
    reminders: t.field({
      type: [ReminderType],
      description: 'Reminders attached to this item, sorted by dueDate asc',
      resolve: (item, _args, ctx) => ReminderQuery.byItem(ctx.userId, item.id),
    }),
    createdAt: t.expose('createdAt', { type: 'DateTime', description: 'Creation date' }),
    updatedAt: t.expose('updatedAt', { type: 'DateTime', description: 'Last update date' }),
    location: t.field({
      type: LocationPathType,
      nullable: true,
      description: 'Resolved location path (storage or zone level)',
      resolve: (item, _args, ctx) => ctx.loaders.locationPath(item),
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
