import { builder } from '~/domain/shared/graphql/builder'
import { buildDashboard } from '../../read-model'
import { DashboardType } from './types'

builder.queryField('dashboard', (t) =>
  t.field({
    type: DashboardType,
    description: 'Dashboard with inventory statistics',
    resolve: () => buildDashboard(),
  }),
)
