import type { Brand } from 'ts-brand'
import type { PlaceId, StorageId } from '~/domain/location/types'
import type { UserId } from '~/domain/shared/types'

export type ItemId = Brand<string, 'ItemId'>
export type ItemName = Brand<string, 'ItemName'>
export type Quantity = Brand<number, 'Quantity'>

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

export type Item = {
  id: ItemId
  userId: UserId
  name: ItemName
  description: string
  category: ItemCategory
  quantity: Quantity
  storageId: StorageId | null
  placeId: PlaceId | null
  addedBy: UserId
  personalNotes: string
  purchaseDate: Date | null
  purchaseLocation: string
  createdAt: Date
  updatedAt: Date
}
