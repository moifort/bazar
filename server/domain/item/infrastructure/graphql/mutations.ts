import { GraphQLError } from 'graphql'
import { builder } from '~/domain/shared/graphql/builder'
import { ItemCommand } from '../../command'
import { AddItemInput, ConfirmItemInput, UpdateItemInput } from './inputs'
import { ItemType } from './types'

builder.mutationField('addItem', (t) =>
  t.field({
    type: ItemType,
    description: 'Manually add a new item to the inventory',
    args: { input: t.arg({ type: AddItemInput, required: true }) },
    resolve: (_root, { input }, ctx) => ItemCommand.add({ ...input, addedBy: ctx.userTag }),
  }),
)

builder.mutationField('updateItem', (t) =>
  t.field({
    type: ItemType,
    description: 'Update an existing item',
    args: {
      id: t.arg({ type: 'ItemId', required: true }),
      input: t.arg({ type: UpdateItemInput, required: true }),
    },
    resolve: async (_root, { id, input }) => {
      const result = await ItemCommand.update(id, input)
      if (result === 'not-found')
        throw new GraphQLError('Item not found', { extensions: { code: 'NOT_FOUND' } })
      return result.item
    },
  }),
)

builder.mutationField('deleteItem', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Delete an item and its photo',
    args: { id: t.arg({ type: 'ItemId', required: true }) },
    resolve: async (_root, { id }) => {
      const result = await ItemCommand.remove(id)
      if (result === 'not-found')
        throw new GraphQLError('Item not found', { extensions: { code: 'NOT_FOUND' } })
      return true
    },
  }),
)

builder.mutationField('moveItem', (t) =>
  t.field({
    type: ItemType,
    description: 'Move an item to a different storage location',
    args: {
      id: t.arg({ type: 'ItemId', required: true }),
      storageId: t.arg({ type: 'StorageId', required: true }),
    },
    resolve: async (_root, { id, storageId }) => {
      const result = await ItemCommand.move(id, storageId)
      if (result === 'not-found')
        throw new GraphQLError('Item not found', { extensions: { code: 'NOT_FOUND' } })
      if (result === 'storage-not-found')
        throw new GraphQLError('Storage not found', { extensions: { code: 'NOT_FOUND' } })
      return result.item
    },
  }),
)

builder.mutationField('confirmItems', (t) =>
  t.field({
    type: [ItemType],
    description: 'Confirm and create items from a scan preview',
    args: {
      input: t.arg({ type: [ConfirmItemInput], required: true }),
    },
    resolve: (_root, { input }, ctx) =>
      ItemCommand.confirmItems(input.map((i) => ({ ...i, addedBy: ctx.userTag }))),
  }),
)
