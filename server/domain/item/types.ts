import type { Brand } from 'ts-brand'
import type { ImageId } from '~/domain/image/types'
import type { PlaceId, StorageId } from '~/domain/location/types'
import type { UserTag } from '~/domain/shared/types'

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
  name: ItemName
  description: string
  category: ItemCategory
  quantity: Quantity
  photoImageId: ImageId | null
  storageId: StorageId | null
  placeId: PlaceId | null
  addedBy: UserTag
  personalNotes: string
  purchaseDate: Date | null
  purchaseLocation: string
  invoiceImageId: ImageId | null
  createdAt: Date
  updatedAt: Date
}
