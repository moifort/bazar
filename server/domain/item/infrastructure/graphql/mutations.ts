import { match, P } from 'ts-pattern'
import { builder } from '~/domain/shared/graphql/builder'
import { domainError } from '~/domain/shared/graphql/errors'
import { ItemCommand } from '../../command'
import { ItemUseCase } from '../../use-case'
import { AddItemInput, ConfirmItemInput, MoveItemInput, UpdateItemInput } from './inputs'
import { ItemType } from './types'

builder.mutationField('addItem', (t) =>
  t.field({
    type: ItemType,
    description: 'Manually add a new item to the inventory',
    args: { input: t.arg({ type: AddItemInput, required: true }) },
    resolve: async (_root, { input }, ctx) =>
      match(await ItemUseCase.add(ctx.userId, input))
        .with('invalid-location', 'location-not-found', domainError)
        .with(P.not(P.string), (item) => item)
        .exhaustive(),
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
    resolve: async (_root, { id, input }, ctx) =>
      match(await ItemCommand.update(ctx.userId, id, input))
        .with('not-found', domainError)
        .with(P.not(P.string), (item) => item)
        .exhaustive(),
  }),
)

builder.mutationField('deleteItem', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Delete an item, together with the reminders attached to it',
    args: { id: t.arg({ type: 'ItemId', required: true }) },
    resolve: async (_root, { id }, ctx) =>
      match(await ItemUseCase.remove(ctx.userId, id))
        .with('not-found', domainError)
        .with('deleted', () => true)
        .exhaustive(),
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
    resolve: async (_root, { id, target }, ctx) =>
      match(await ItemUseCase.move(ctx.userId, id, target))
        .with('not-found', 'invalid-location', 'location-not-found', domainError)
        .with(P.not(P.string), (item) => item)
        .exhaustive(),
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
      const results = await ItemUseCase.confirmScanned(ctx.userId, input)
      return results.map((result) =>
        match(result)
          .with('invalid-location', 'location-not-found', domainError)
          .with(P.not(P.string), (item) => item)
          .exhaustive(),
      )
    },
  }),
)
