import { builder } from '~/domain/shared/graphql/builder'
import { ItemCategoryEnum, PurchaseConditionEnum } from './enums'

export const AddItemInput = builder.inputType('AddItemInput', {
  description: 'Input for manually adding a new item',
  fields: (t) => ({
    name: t.field({ type: 'ItemName', required: true, description: 'Item name' }),
    description: t.string({ description: 'Item description' }),
    category: t.field({ type: ItemCategoryEnum, required: true, description: 'Item category' }),
    quantity: t.field({ type: 'Quantity', description: 'Quantity (default 1)' }),
    storageId: t.field({
      type: 'StorageId',
      description: 'Storage attachment (mutually exclusive with zoneId)',
    }),
    zoneId: t.field({
      type: 'ZoneId',
      description: 'Zone attachment when no storage is chosen (mutually exclusive with storageId)',
    }),
    personalNotes: t.string({ description: 'Personal notes' }),
    purchaseDate: t.field({ type: 'DateTime', description: 'Date the item was purchased' }),
    purchaseLocation: t.string({ description: 'Where the item was purchased' }),
    purchaseCondition: t.field({
      type: PurchaseConditionEnum,
      description: 'Whether the item was bought new or used',
    }),
  }),
})

export const UpdateItemInput = builder.inputType('UpdateItemInput', {
  description: 'Input for updating an existing item. Absent fields preserve the current value.',
  fields: (t) => ({
    name: t.field({ type: 'ItemName', description: 'New item name' }),
    description: t.string({ description: 'New description' }),
    category: t.field({ type: ItemCategoryEnum, description: 'New category' }),
    quantity: t.field({ type: 'Quantity', description: 'New quantity' }),
    personalNotes: t.string({ description: 'New personal notes' }),
    purchaseDate: t.field({ type: 'DateTime', description: 'New purchase date (null to clear)' }),
    purchaseLocation: t.string({ description: 'New purchase location (empty string to clear)' }),
    purchaseCondition: t.field({
      type: PurchaseConditionEnum,
      description: 'New purchase condition (omit to leave unchanged)',
    }),
  }),
})

export const MoveItemInput = builder.inputType('MoveItemInput', {
  description: 'Target location for moving an item (zone or storage, mutually exclusive)',
  fields: (t) => ({
    storageId: t.field({ type: 'StorageId', description: 'Move to a storage' }),
    zoneId: t.field({ type: 'ZoneId', description: 'Move to a zone (no storage)' }),
  }),
})

export const ConfirmItemInput = builder.inputType('ConfirmItemInput', {
  description: 'Input for confirming a scanned item',
  fields: (t) => ({
    name: t.field({ type: 'ItemName', required: true, description: 'Item name' }),
    description: t.string({ description: 'Item description' }),
    category: t.field({ type: ItemCategoryEnum, required: true, description: 'Item category' }),
    quantity: t.field({ type: 'Quantity', description: 'Quantity (default 1)' }),
    storageId: t.field({
      type: 'StorageId',
      description: 'Storage attachment (mutually exclusive with zoneId)',
    }),
    zoneId: t.field({ type: 'ZoneId', description: 'Zone attachment when no storage is chosen' }),
    personalNotes: t.string({ description: 'Personal notes' }),
    purchaseDate: t.field({ type: 'DateTime', description: 'Date the item was purchased' }),
    purchaseLocation: t.string({ description: 'Where the item was purchased' }),
    purchaseCondition: t.field({
      type: PurchaseConditionEnum,
      description: 'Whether the item was bought new or used',
    }),
  }),
})
