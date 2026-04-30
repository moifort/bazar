import type { UserId } from '~/domain/shared/types'
import type { Item, ItemId, ItemName, LowStockThreshold, Quantity } from './types'

export type ItemEvent =
  | { type: 'item-added'; item: Item }
  | { type: 'item-updated'; item: Item }
  | { type: 'item-removed'; itemId: string }
  | { type: 'item-moved'; item: Item }

export type LowStockCrossedEvent = {
  userId: UserId
  itemId: ItemId
  name: ItemName
  newQuantity: Quantity
  threshold: LowStockThreshold
}

export const detectThresholdCrossing = (
  before: Pick<Item, 'quantity' | 'lowStockThreshold'>,
  after: Pick<Item, 'quantity' | 'lowStockThreshold'>,
): boolean => {
  const newThreshold = after.lowStockThreshold
  if (newThreshold == null || after.quantity > newThreshold) return false
  const beforeWasLow =
    before.lowStockThreshold != null && before.quantity <= before.lowStockThreshold
  return !beforeWasLow
}
