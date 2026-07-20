import { countBy, sortBy } from 'lodash-es'
import { ItemQuery } from '~/domain/item/query'
import type { ItemCategory } from '~/domain/item/types'
import { LocationQuery } from '~/domain/location/query'
import type { PlaceName } from '~/domain/location/types'
import type { UserId } from '~/domain/shared/types'
import type { CategoryCount, Dashboard, PlaceCount } from './types'

const UNKNOWN_PLACE = 'Inconnu' as PlaceName

const view = async (userId: UserId): Promise<Dashboard> => {
  const [items, places] = await Promise.all([
    ItemQuery.all(userId),
    LocationQuery.allPlaces(userId),
  ])

  const itemsByCategory: CategoryCount[] = sortBy(
    Object.entries(countBy(items, ({ category }) => category)).map(([category, count]) => ({
      category: category as ItemCategory,
      count,
    })),
    ({ count }) => -count,
  )

  const placeNames = new Map(places.map((place) => [place.id as string, place.name]))
  const itemsByPlace: PlaceCount[] = sortBy(
    Object.entries(
      countBy(
        items.filter(({ placeId }) => placeId),
        ({ placeId }) => placeId,
      ),
    ).map(([placeId, count]) => ({
      placeId,
      placeName: placeNames.get(placeId) ?? UNKNOWN_PLACE,
      count,
    })),
    ({ count }) => -count,
  )

  const lowStockItems = items
    .filter(({ quantity, lowStockThreshold }) => lowStockThreshold && quantity <= lowStockThreshold)
    .sort((a, b) => a.name.localeCompare(b.name))

  return {
    totalItems: items.length,
    itemsByCategory,
    itemsByPlace,
    recentItems: items.slice(0, 10),
    lowStockItems,
  }
}

export const DashboardQuery = { view }
