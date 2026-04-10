import { builder } from '~/domain/shared/graphql/builder'
import { LocationQuery } from '../../query'
import { PlaceType } from './types'

builder.queryField('places', (t) =>
  t.field({
    type: [PlaceType],
    description: 'All places with nested rooms, zones, and storages',
    resolve: () => LocationQuery.allPlaces(),
  }),
)
