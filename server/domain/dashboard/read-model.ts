import { countBy, sortBy } from 'lodash-es'
import * as itemRepository from '~/domain/item/infrastructure/repository'
import type { ItemCategory } from '~/domain/item/types'
import * as locationRepository from '~/domain/location/infrastructure/repository'
import type { PlaceName } from '~/domain/location/types'
import type { CategoryCount, Dashboard, PlaceCount } from './types'

export const buildDashboard = async (): Promise<Dashboard> => {
  const items = await itemRepository.findAll()
  const places = await locationRepository.findAllPlaces()

  const categoryCounts = countBy(items, ({ category }) => category)
  const itemsByCategory: CategoryCount[] = sortBy(
    Object.entries(categoryCounts).map(([category, count]) => ({
      category: category as ItemCategory,
      count,
    })),
    ({ count }) => -count,
  )

  const placeCounts = countBy(
    items.filter((item) => item.placeId),
    ({ placeId }) => placeId,
  )
  const placeMap = new Map(places.map((place) => [place.id as string, place.name]))
  const itemsByPlace: PlaceCount[] = sortBy(
    Object.entries(placeCounts).map(([placeId, count]) => ({
      placeId,
      placeName: (placeMap.get(placeId) ?? 'Inconnu') as PlaceName,
      count,
    })),
    ({ count }) => -count,
  )

  const recentItems = items.slice(0, 10)

  return {
    totalItems: items.length,
    itemsByCategory,
    itemsByPlace,
    recentItems,
  }
}
