import { builder } from '~/domain/shared/graphql/builder'
import { DashboardQuery } from '../../query'
import { DashboardType } from './types'

builder.queryField('dashboard', (t) =>
  t.field({
    type: DashboardType,
    description: 'Dashboard with inventory statistics',
    resolve: (_root, _args, ctx) => DashboardQuery.view(ctx.userId),
  }),
)
