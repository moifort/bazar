import { builder } from '~/domain/shared/graphql/builder'
import { ItemQuery } from '../../query'
import { ItemCategoryEnum, ItemSortEnum, SortOrderEnum } from './enums'
import { ItemsType, ItemType } from './types'

builder.queryField('items', (t) =>
  t.field({
    type: ItemsType,
    description: 'List items with optional filters and pagination',
    args: {
      category: t.arg({ type: ItemCategoryEnum, description: 'Filter by category' }),
      placeId: t.arg({ type: 'PlaceId', description: 'Filter by place' }),
      roomId: t.arg({ type: 'RoomId', description: 'Filter by room' }),
      search: t.arg.string({ description: 'Search in name, description, notes' }),
      sort: t.arg({ type: ItemSortEnum, description: 'Sort field' }),
      order: t.arg({ type: SortOrderEnum, description: 'Sort direction' }),
      offset: t.arg.int({ description: 'Pagination offset' }),
      limit: t.arg.int({ description: 'Pagination limit (default 40)' }),
    },
    resolve: (_root, args) => ItemQuery.allItems(args),
  }),
)

builder.queryField('item', (t) =>
  t.field({
    type: ItemType,
    nullable: true,
    description: 'Get a single item by ID',
    args: {
      id: t.arg({ type: 'ItemId', required: true, description: 'Item identifier' }),
    },
    resolve: (_root, { id }) => ItemQuery.itemById(id),
  }),
)
