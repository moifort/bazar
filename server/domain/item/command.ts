import { randomUUID } from 'node:crypto'
import { LocationQuery } from '~/domain/location/query'
import type { StorageId, ZoneId } from '~/domain/location/types'
import { ReminderCommand } from '~/domain/reminder/command'
import type { UserId } from '~/domain/shared/types'
import { emit } from '~/system/event-bus'
import * as repository from './infrastructure/repository'
import {
  ItemName,
  ItemId as makeItemId,
  parseItemCategory,
  parsePurchaseCondition,
  parsePurchaseDate,
  parsePurchaseLocation,
  Quantity,
} from './primitives'
import type { Item, ItemId, PurchaseCondition } from './types'

type LocationAttachmentInput = {
  storageId?: string | null
  zoneId?: string | null
}

type ResolvedAttachment = Pick<Item, 'storageId' | 'zoneId' | 'placeId'>

const resolveAttachment = async (
  userId: UserId,
  input: LocationAttachmentInput,
): Promise<ResolvedAttachment | 'invalid-location' | 'location-not-found'> => {
  if (input.storageId && input.zoneId) return 'invalid-location'

  if (input.storageId) {
    const path = await LocationQuery.resolveLocationPath(userId, input.storageId as StorageId)
    if (!path) return 'location-not-found'
    return {
      storageId: input.storageId as StorageId,
      zoneId: null,
      placeId: path.place.id,
    }
  }

  if (input.zoneId) {
    const path = await LocationQuery.resolveZoneLocationPath(userId, input.zoneId as ZoneId)
    if (!path) return 'location-not-found'
    return {
      storageId: null,
      zoneId: input.zoneId as ZoneId,
      placeId: path.place.id,
    }
  }

  return { storageId: null, zoneId: null, placeId: null }
}

type AddItemInput = {
  userId: UserId
  name: string
  description?: string | null
  category: string
  quantity?: number | null
  storageId?: string | null
  zoneId?: string | null
  personalNotes?: string | null
  purchaseDate?: Date | string | null
  purchaseLocation?: string | null
  purchaseCondition?: PurchaseCondition | string | null
}

const add = async (input: AddItemInput) => {
  const attachment = await resolveAttachment(input.userId, {
    storageId: input.storageId,
    zoneId: input.zoneId,
  })
  if (attachment === 'invalid-location' || attachment === 'location-not-found') return attachment

  const item: Item = {
    id: makeItemId(randomUUID()),
    userId: input.userId,
    name: ItemName(input.name),
    description: input.description ?? '',
    category: parseItemCategory(input.category),
    quantity: Quantity(input.quantity ?? 1),
    storageId: attachment.storageId,
    zoneId: attachment.zoneId,
    placeId: attachment.placeId,
    addedBy: input.userId,
    personalNotes: input.personalNotes ?? '',
    purchaseDate: input.purchaseDate ? parsePurchaseDate(input.purchaseDate) : null,
    purchaseLocation: input.purchaseLocation ? parsePurchaseLocation(input.purchaseLocation) : '',
    purchaseCondition: input.purchaseCondition
      ? parsePurchaseCondition(input.purchaseCondition)
      : null,
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
  purchaseCondition?: PurchaseCondition | string | null
}

const update = async (userId: UserId, id: ItemId, input: UpdateItemInput) => {
  const item = await repository.findBy(userId, id)
  if (!item) return 'not-found' as const

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
    purchaseCondition:
      input.purchaseCondition !== undefined
        ? input.purchaseCondition
          ? parsePurchaseCondition(input.purchaseCondition)
          : null
        : item.purchaseCondition,
    updatedAt: new Date(),
  }

  await repository.save(updated)
  await emit('item-changed', { type: 'item-updated' as const, item: updated })
  return { tag: 'updated' as const, item: updated }
}

const remove = async (userId: UserId, id: ItemId) => {
  const item = await repository.findBy(userId, id)
  if (!item) return 'not-found' as const

  await ReminderCommand.removeByItem(userId, id)
  await repository.remove(id)
  await emit('item-changed', { type: 'item-removed' as const, itemId: id })
  return 'deleted' as const
}

const move = async (userId: UserId, id: ItemId, target: LocationAttachmentInput) => {
  const item = await repository.findBy(userId, id)
  if (!item) return 'not-found' as const

  const attachment = await resolveAttachment(userId, target)
  if (attachment === 'invalid-location') return 'invalid-location' as const
  if (attachment === 'location-not-found') return 'location-not-found' as const

  const updated: Item = {
    ...item,
    storageId: attachment.storageId,
    zoneId: attachment.zoneId,
    placeId: attachment.placeId,
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
  zoneId?: string | null
  personalNotes?: string | null
  purchaseDate?: Date | string | null
  purchaseLocation?: string | null
  purchaseCondition?: PurchaseCondition | string | null
}

const confirmItems = async (userId: UserId, inputs: ConfirmItemInput[]) =>
  Promise.all(inputs.map((input) => add({ ...input, userId })))

export const ItemCommand = { add, update, remove, move, confirmItems }
