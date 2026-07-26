import type { Brand } from 'ts-brand'
import type { PlaceId, StorageId, ZoneId } from '~/domain/location/types'
import type { UserId } from '~/domain/shared/types'

export type ItemId = Brand<string, 'ItemId'>
export type ItemName = Brand<string, 'ItemName'>
export type ItemTag = Brand<string, 'ItemTag'>
export type Quantity = Brand<number, 'Quantity'>
export type LowStockThreshold = Brand<number, 'LowStockThreshold'>

export type ItemCategory =
  | 'tools'
  | 'appliances'
  | 'decor'
  | 'clothing'
  | 'documents'
  | 'food'
  | 'electronics'
  | 'furniture'
  | 'kitchenware'
  | 'linen'
  | 'sports'
  | 'toys'
  | 'books'
  | 'media'
  | 'hygiene'
  | 'other'

export type ItemSort = 'name' | 'category' | 'created-at' | 'updated-at'

export type PurchaseCondition = 'new' | 'used'

export type Item = {
  id: ItemId
  userId: UserId
  name: ItemName
  description: string
  /** Keywords the item can be searched by — what is written on the units it
   * groups ("cumin", "paprika") and what describes it ("condiment", "cuisine").
   * Always present, empty when the item carries none. */
  tags: ItemTag[]
  category: ItemCategory
  quantity: Quantity
  storageId?: StorageId
  zoneId?: ZoneId
  placeId?: PlaceId
  addedBy: UserId
  personalNotes: string
  purchaseDate?: Date
  purchaseLocation: string
  purchaseCondition?: PurchaseCondition
  lowStockThreshold?: LowStockThreshold
  createdAt: Date
  updatedAt: Date
}
