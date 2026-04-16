import { randomUUID } from 'node:crypto'
import { ImageCommand } from '~/domain/image/command'
import { LocationQuery } from '~/domain/location/query'
import type { StorageId } from '~/domain/location/types'
import { ReminderCommand } from '~/domain/reminder/command'
import { UserTag } from '~/domain/shared/primitives'
import { emit } from '~/system/event-bus'
import * as repository from './infrastructure/repository'
import {
  ItemId,
  ItemName,
  parseItemCategory,
  parsePurchaseDate,
  parsePurchaseLocation,
  Quantity,
} from './primitives'
import type { Item } from './types'

type AddItemInput = {
  name: string
  description?: string | null
  category: string
  quantity?: number | null
  photoBase64?: string | null
  storageId?: string | null
  personalNotes?: string | null
  addedBy: string
  purchaseDate?: Date | string | null
  purchaseLocation?: string | null
  invoiceImageBase64?: string | null
}

const add = async (input: AddItemInput) => {
  let photoImageId: Item['photoImageId'] = null
  if (input.photoBase64) {
    const image = await ImageCommand.save(input.photoBase64, 'image/jpeg')
    photoImageId = image.id
  }

  let invoiceImageId: Item['invoiceImageId'] = null
  if (input.invoiceImageBase64) {
    const image = await ImageCommand.save(input.invoiceImageBase64, 'image/jpeg')
    invoiceImageId = image.id
  }

  let placeId: Item['placeId'] = null
  if (input.storageId) {
    const path = await LocationQuery.resolveLocationPath(input.storageId as StorageId)
    if (path) placeId = path.place.id
  }

  const item: Item = {
    id: ItemId(randomUUID()),
    name: ItemName(input.name),
    description: input.description ?? '',
    category: parseItemCategory(input.category),
    quantity: Quantity(input.quantity ?? 1),
    photoImageId,
    storageId: input.storageId ? (input.storageId as StorageId) : null,
    placeId,
    addedBy: UserTag(input.addedBy),
    personalNotes: input.personalNotes ?? '',
    purchaseDate: input.purchaseDate ? parsePurchaseDate(input.purchaseDate) : null,
    purchaseLocation: input.purchaseLocation ? parsePurchaseLocation(input.purchaseLocation) : '',
    invoiceImageId,
    createdAt: new Date(),
    updatedAt: new Date(),
  }

  await repository.save(item)
  await emit('item-changed', { type: 'item-added' as const, item })
  return item
}

type UpdateItemInput = {
  name?: string | null
  description?: string | null
  category?: string | null
  quantity?: number | null
  personalNotes?: string | null
  purchaseDate?: Date | string | null
  purchaseLocation?: string | null
  invoiceImageBase64?: string | null
}

const update = async (id: string, input: UpdateItemInput) => {
  const item = await repository.findBy(id)
  if (!item) return 'not-found' as const

  let invoiceImageId = item.invoiceImageId
  if (input.invoiceImageBase64 !== undefined) {
    if (item.invoiceImageId) await ImageCommand.remove(item.invoiceImageId)
    invoiceImageId = input.invoiceImageBase64
      ? (await ImageCommand.save(input.invoiceImageBase64, 'image/jpeg')).id
      : null
  }

  const updated: Item = {
    ...item,
    name: input.name ? ItemName(input.name) : item.name,
    description: input.description !== undefined ? (input.description ?? '') : item.description,
    category: input.category ? parseItemCategory(input.category) : item.category,
    quantity: input.quantity ? Quantity(input.quantity) : item.quantity,
    personalNotes:
      input.personalNotes !== undefined ? (input.personalNotes ?? '') : item.personalNotes,
    purchaseDate:
      input.purchaseDate !== undefined
        ? input.purchaseDate
          ? parsePurchaseDate(input.purchaseDate)
          : null
        : item.purchaseDate,
    purchaseLocation:
      input.purchaseLocation !== undefined
        ? parsePurchaseLocation(input.purchaseLocation ?? '')
        : item.purchaseLocation,
    invoiceImageId,
    updatedAt: new Date(),
  }

  await repository.save(updated)
  await emit('item-changed', { type: 'item-updated' as const, item: updated })
  return { tag: 'updated' as const, item: updated }
}

const remove = async (id: string) => {
  const item = await repository.findBy(id)
  if (!item) return 'not-found' as const

  if (item.photoImageId) {
    await ImageCommand.remove(item.photoImageId)
  }
  if (item.invoiceImageId) {
    await ImageCommand.remove(item.invoiceImageId)
  }
  await ReminderCommand.removeByItem(id)

  await repository.remove(id)
  await emit('item-changed', { type: 'item-removed' as const, itemId: id })
  return 'deleted' as const
}

const move = async (id: string, storageId: string) => {
  const item = await repository.findBy(id)
  if (!item) return 'not-found' as const

  const path = await LocationQuery.resolveLocationPath(storageId as StorageId)
  if (!path) return 'storage-not-found' as const

  const updated: Item = {
    ...item,
    storageId: storageId as StorageId,
    placeId: path.place.id,
    updatedAt: new Date(),
  }

  await repository.save(updated)
  await emit('item-changed', { type: 'item-moved' as const, item: updated })
  return { tag: 'moved' as const, item: updated }
}

type ConfirmItemInput = {
  name: string
  description?: string | null
  category: string
  quantity?: number | null
  storageId?: string | null
  addedBy: string
  previewImageBase64?: string | null
}

const confirmItems = async (inputs: ConfirmItemInput[]) => {
  const items = await Promise.all(
    inputs.map((input) =>
      add({
        name: input.name,
        description: input.description,
        category: input.category,
        quantity: input.quantity,
        photoBase64: input.previewImageBase64,
        storageId: input.storageId,
        personalNotes: null,
        addedBy: input.addedBy,
      }),
    ),
  )
  return items
}

export const ItemCommand = { add, update, remove, move, confirmItems }
