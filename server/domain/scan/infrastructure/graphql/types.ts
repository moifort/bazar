import { builder } from '~/domain/shared/graphql/builder'
import type { ItemPreview } from '../../types'

export const ItemPreviewType = builder.objectRef<ItemPreview>('ItemPreview').implement({
  description: 'Preview of an item identified by AI from a photo',
  fields: (t) => ({
    previewId: t.exposeString('previewId', { description: 'Preview identifier' }),
    name: t.exposeString('name', { description: 'Identified item name' }),
    category: t.exposeString('category', {
      nullable: true,
      description: 'Suggested category',
    }),
    description: t.exposeString('description', { description: 'Item description' }),
    quantity: t.exposeInt('quantity', { description: 'Number of identical items' }),
  }),
})
