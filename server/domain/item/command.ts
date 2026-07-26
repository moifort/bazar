import { randomUUID } from 'node:crypto'
import type { PlaceId, StorageId, ZoneId } from '~/domain/location/types'
import type { UserId } from '~/domain/shared/types'
import { emit } from '~/system/event-bus'
import { detectThresholdCrossing, type LowStockCrossedEvent } from './events'
import * as repository from './infrastructure/repository'
import {
  ItemName,
  LowStockThreshold,
  ItemId as makeItemId,
  parseItemCategory,
  parseItemTags,
  parsePurchaseCondition,
  parsePurchaseDate,
  parsePurchaseLocation,
  Quantity,
} from './primitives'
import type { Item, ItemId, PurchaseCondition } from './types'

/**
 * Where the item sits, already resolved against the location tree. Resolving it
 * belongs to `use-case.ts` — the command only stores what it is handed.
 */
export type Attachment = {
  storageId?: StorageId
  zoneId?: ZoneId
  placeId?: PlaceId
}

export const NO_ATTACHMENT: Attachment = {}

type AddItemInput = {
  userId: UserId
  name: string
  description?: string | null
  tags?: string[] | null
  category: string
  quantity?: number | null
  attachment: Attachment
  personalNotes?: string | null
  purchaseDate?: Date | string | null
  purchaseLocation?: string | null
  purchaseCondition?: PurchaseCondition | string | null
  lowStockThreshold?: number | null
}

const add = async (input: AddItemInput) => {
  const item: Item = {
    id: makeItemId(randomUUID()),
    userId: input.userId,
    name: ItemName(input.name),
    description: input.description ?? '',
    tags: parseItemTags(input.tags ?? []),
    category: parseItemCategory(input.category),
    quantity: Quantity(input.quantity ?? 1),
    ...input.attachment,
    addedBy: input.userId,
    personalNotes: input.personalNotes ?? '',
    purchaseDate: input.purchaseDate ? parsePurchaseDate(input.purchaseDate) : undefined,
    purchaseLocation: input.purchaseLocation ? parsePurchaseLocation(input.purchaseLocation) : '',
    purchaseCondition: input.purchaseCondition
      ? parsePurchaseCondition(input.purchaseCondition)
      : undefined,
    lowStockThreshold:
      input.lowStockThreshold != null ? LowStockThreshold(input.lowStockThreshold) : undefined,
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
  tags?: string[] | null
  category?: string | null
  quantity?: number | null
  personalNotes?: string | null
  purchaseDate?: Date | string | null
  purchaseLocation?: string | null
  purchaseCondition?: PurchaseCondition | string | null
  lowStockThreshold?: number | null
}

const update = async (userId: UserId, id: ItemId, input: UpdateItemInput) => {
  const item = await repository.findBy(userId, id)
  if (!item) return 'not-found' as const

  const updated: Item = {
    ...item,
    name: input.name ? ItemName(input.name) : item.name,
    description: input.description !== undefined ? (input.description ?? '') : item.description,
    tags: input.tags !== undefined ? parseItemTags(input.tags ?? []) : item.tags,
    category: input.category ? parseItemCategory(input.category) : item.category,
    quantity: input.quantity ? Quantity(input.quantity) : item.quantity,
    personalNotes:
      input.personalNotes !== undefined ? (input.personalNotes ?? '') : item.personalNotes,
    purchaseDate:
      input.purchaseDate !== undefined
        ? input.purchaseDate
          ? parsePurchaseDate(input.purchaseDate)
          : undefined
        : item.purchaseDate,
    purchaseLocation:
      input.purchaseLocation !== undefined
        ? parsePurchaseLocation(input.purchaseLocation ?? '')
        : item.purchaseLocation,
    purchaseCondition:
      input.purchaseCondition !== undefined
        ? input.purchaseCondition
          ? parsePurchaseCondition(input.purchaseCondition)
          : undefined
        : item.purchaseCondition,
    lowStockThreshold:
      input.lowStockThreshold !== undefined
        ? input.lowStockThreshold != null
          ? LowStockThreshold(input.lowStockThreshold)
          : undefined
        : item.lowStockThreshold,
    updatedAt: new Date(),
  }

  await repository.save(updated)
  await emit('item-changed', { type: 'item-updated' as const, item: updated })
  if (detectThresholdCrossing(item, updated) && updated.lowStockThreshold != null) {
    const event: LowStockCrossedEvent = {
      userId: updated.userId,
      itemId: updated.id,
      name: updated.name,
      newQuantity: updated.quantity,
      threshold: updated.lowStockThreshold,
    }
    await emit('low-stock-crossed', event)
  }
  return updated
}

const remove = async (userId: UserId, id: ItemId) => {
  const item = await repository.findBy(userId, id)
  if (!item) return 'not-found' as const

  await repository.remove(id)
  await emit('item-changed', { type: 'item-removed' as const, itemId: id })
  return 'deleted' as const
}

const move = async (userId: UserId, id: ItemId, attachment: Attachment) => {
  const item = await repository.findBy(userId, id)
  if (!item) return 'not-found' as const

  // Assigned field by field, never spread: an attachment with no key at all is
  // a detach, and spreading it would leave the previous location in place.
  const moved: Item = {
    ...item,
    storageId: attachment.storageId,
    zoneId: attachment.zoneId,
    placeId: attachment.placeId,
    updatedAt: new Date(),
  }

  await repository.save(moved)
  await emit('item-changed', { type: 'item-moved' as const, item: moved })
  return moved
}

// Every item of one owner, gone. Reminders are the reminder domain's own
// business — the account use case asks it directly.
const forget = (userId: UserId): Promise<void> => repository.removeAllByUser(userId)

export const ItemCommand = { add, update, remove, move, forget }
