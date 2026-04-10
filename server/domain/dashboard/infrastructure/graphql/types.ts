import { ItemCategoryEnum } from '~/domain/item/infrastructure/graphql/enums'
import { ItemType } from '~/domain/item/infrastructure/graphql/types'
import { builder } from '~/domain/shared/graphql/builder'
import type { CategoryCount, Dashboard, PlaceCount } from '../../types'

const CategoryCountType = builder.objectRef<CategoryCount>('CategoryCount').implement({
  description: 'Item count per category',
  fields: (t) => ({
    category: t.expose('category', { type: ItemCategoryEnum, description: 'Item category' }),
    count: t.exposeInt('count', { description: 'Number of items in this category' }),
  }),
})

const PlaceCountType = builder.objectRef<PlaceCount>('PlaceCount').implement({
  description: 'Item count per place',
  fields: (t) => ({
    placeId: t.exposeString('placeId', { description: 'Place identifier' }),
    placeName: t.expose('placeName', { type: 'PlaceName', description: 'Place display name' }),
    count: t.exposeInt('count', { description: 'Number of items in this place' }),
  }),
})

export const DashboardType = builder.objectRef<Dashboard>('Dashboard').implement({
  description: 'Dashboard with inventory statistics',
  fields: (t) => ({
    totalItems: t.exposeInt('totalItems', { description: 'Total number of items' }),
    itemsByCategory: t.field({
      type: [CategoryCountType],
      description: 'Item counts grouped by category',
      resolve: (dashboard) => dashboard.itemsByCategory,
    }),
    itemsByPlace: t.field({
      type: [PlaceCountType],
      description: 'Item counts grouped by place',
      resolve: (dashboard) => dashboard.itemsByPlace,
    }),
    recentItems: t.field({
      type: [ItemType],
      description: 'Most recently added items',
      resolve: (dashboard) => dashboard.recentItems,
    }),
  }),
})
