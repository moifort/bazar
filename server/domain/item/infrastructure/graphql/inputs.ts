import { builder } from '~/domain/shared/graphql/builder'
import { ItemCategoryEnum } from './enums'

export const AddItemInput = builder.inputType('AddItemInput', {
  description: 'Input for manually adding a new item',
  fields: (t) => ({
    name: t.field({ type: 'ItemName', required: true, description: 'Item name' }),
    description: t.string({ description: 'Item description' }),
    category: t.field({ type: ItemCategoryEnum, required: true, description: 'Item category' }),
    quantity: t.field({ type: 'Quantity', description: 'Quantity (default 1)' }),
    storageId: t.field({ type: 'StorageId', description: 'Storage location' }),
    personalNotes: t.string({ description: 'Personal notes' }),
    purchaseDate: t.field({ type: 'DateTime', description: 'Date the item was purchased' }),
    purchaseLocation: t.string({ description: 'Where the item was purchased' }),
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
  }),
})

export const ConfirmItemInput = builder.inputType('ConfirmItemInput', {
  description: 'Input for confirming a scanned item',
  fields: (t) => ({
    name: t.field({ type: 'ItemName', required: true, description: 'Item name' }),
    description: t.string({ description: 'Item description' }),
    category: t.field({ type: ItemCategoryEnum, required: true, description: 'Item category' }),
    quantity: t.field({ type: 'Quantity', description: 'Quantity (default 1)' }),
    storageId: t.field({ type: 'StorageId', description: 'Storage location' }),
  }),
})
