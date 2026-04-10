import { builder } from '~/domain/shared/graphql/builder'
import { ItemCategoryEnum } from './enums'

export const AddItemInput = builder.inputType('AddItemInput', {
  description: 'Input for manually adding a new item',
  fields: (t) => ({
    name: t.field({ type: 'ItemName', required: true, description: 'Item name' }),
    description: t.string({ description: 'Item description' }),
    category: t.field({ type: ItemCategoryEnum, required: true, description: 'Item category' }),
    quantity: t.field({ type: 'Quantity', description: 'Quantity (default 1)' }),
    photoBase64: t.string({ description: 'Photo as base64 encoded string' }),
    storageId: t.field({ type: 'StorageId', description: 'Storage location' }),
    personalNotes: t.string({ description: 'Personal notes' }),
  }),
})

export const UpdateItemInput = builder.inputType('UpdateItemInput', {
  description: 'Input for updating an existing item',
  fields: (t) => ({
    name: t.field({ type: 'ItemName', description: 'New item name' }),
    description: t.string({ description: 'New description' }),
    category: t.field({ type: ItemCategoryEnum, description: 'New category' }),
    quantity: t.field({ type: 'Quantity', description: 'New quantity' }),
    personalNotes: t.string({ description: 'New personal notes' }),
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
    previewImageBase64: t.string({ description: 'Photo from scan preview as base64' }),
  }),
})
