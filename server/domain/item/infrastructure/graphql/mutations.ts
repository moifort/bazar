import { GraphQLError } from 'graphql'
import { builder } from '~/domain/shared/graphql/builder'
import { ItemCommand } from '../../command'
import { AddItemInput, ConfirmItemInput, MoveItemInput, UpdateItemInput } from './inputs'
import { ItemType } from './types'

const invalidLocationError = () =>
  new GraphQLError('Cannot specify both storageId and zoneId', {
    extensions: { code: 'INVALID_LOCATION' },
  })

const locationNotFoundError = () =>
  new GraphQLError('Location not found', { extensions: { code: 'NOT_FOUND' } })

builder.mutationField('addItem', (t) =>
  t.field({
    type: ItemType,
    description: 'Manually add a new item to the inventory',
    args: { input: t.arg({ type: AddItemInput, required: true }) },
    resolve: async (_root, { input }, ctx) => {
      const result = await ItemCommand.add({ ...input, userId: ctx.userId })
      if (result === 'invalid-location') throw invalidLocationError()
      if (result === 'location-not-found') throw locationNotFoundError()
      return result
    },
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
    resolve: async (_root, { id, input }, ctx) => {
      const result = await ItemCommand.update(ctx.userId, id, input)
      if (result === 'not-found')
        throw new GraphQLError('Item not found', { extensions: { code: 'NOT_FOUND' } })
      return result.item
    },
  }),
)

builder.mutationField('deleteItem', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Delete an item',
    args: { id: t.arg({ type: 'ItemId', required: true }) },
    resolve: async (_root, { id }, ctx) => {
      const result = await ItemCommand.remove(ctx.userId, id)
      if (result === 'not-found')
        throw new GraphQLError('Item not found', { extensions: { code: 'NOT_FOUND' } })
      return true
    },
  }),
)

builder.mutationField('moveItem', (t) =>
  t.field({
    type: ItemType,
    description: 'Move an item to a different location (zone or storage, mutually exclusive)',
    args: {
      id: t.arg({ type: 'ItemId', required: true }),
      target: t.arg({ type: MoveItemInput, required: true }),
    },
    resolve: async (_root, { id, target }, ctx) => {
      const result = await ItemCommand.move(ctx.userId, id, target)
      if (result === 'not-found')
        throw new GraphQLError('Item not found', { extensions: { code: 'NOT_FOUND' } })
      if (result === 'invalid-location') throw invalidLocationError()
      if (result === 'location-not-found') throw locationNotFoundError()
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
    resolve: async (_root, { input }, ctx) => {
      const results = await ItemCommand.confirmItems(ctx.userId, input)
      for (const result of results) {
        if (result === 'invalid-location') throw invalidLocationError()
        if (result === 'location-not-found') throw locationNotFoundError()
      }
      return results.filter(
        (r): r is Exclude<typeof r, 'invalid-location' | 'location-not-found'> =>
          r !== 'invalid-location' && r !== 'location-not-found',
      )
    },
  }),
)
