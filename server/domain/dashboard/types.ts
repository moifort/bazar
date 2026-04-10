import type { Item, ItemCategory } from '~/domain/item/types'
import type { PlaceName } from '~/domain/location/types'

export type CategoryCount = {
  category: ItemCategory
  count: number
}

export type PlaceCount = {
  placeId: string
  placeName: PlaceName
  count: number
}

export type Dashboard = {
  totalItems: number
  itemsByCategory: CategoryCount[]
  itemsByPlace: PlaceCount[]
  recentItems: Item[]
}
