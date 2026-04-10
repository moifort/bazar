import { builder } from '~/domain/shared/graphql/builder'

export const ItemCategoryEnum = builder.enumType('ItemCategory', {
  description: 'Category of household item',
  values: {
    tools: { description: 'Tools and hardware' },
    appliances: { description: 'Home appliances' },
    decor: { description: 'Decoration and art' },
    clothing: { description: 'Clothing and accessories' },
    documents: { description: 'Documents and paperwork' },
    food: { description: 'Food and beverages' },
    electronics: { description: 'Electronics and gadgets' },
    furniture: { description: 'Furniture' },
    kitchenware: { description: 'Kitchen items and utensils' },
    linen: { description: 'Bed linen, towels, curtains' },
    sports: { description: 'Sports and outdoor equipment' },
    toys: { description: 'Toys and games' },
    books: { description: 'Books and magazines' },
    media: { description: 'CDs, DVDs, vinyl records' },
    hygiene: { description: 'Hygiene and personal care' },
    other: { description: 'Uncategorized items' },
  },
})

export const ItemSortEnum = builder.enumType('ItemSort', {
  description: 'Sort field for item listing',
  values: {
    name: { description: 'Sort by item name' },
    category: { description: 'Sort by category' },
  },
})

export const SortOrderEnum = builder.enumType('SortOrder', {
  description: 'Sort direction',
  values: {
    asc: { description: 'Ascending' },
    desc: { description: 'Descending' },
  },
})
