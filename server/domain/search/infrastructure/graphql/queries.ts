import { builder } from '~/domain/shared/graphql/builder'
import { SearchQuery } from '../../query'
import { SearchEntryType } from './types'

builder.queryField('search', (t) =>
  t.field({
    type: [SearchEntryType],
    description: 'Full-text search across items and locations',
    args: {
      query: t.arg.string({ required: true, description: 'Search query' }),
      limit: t.arg.int({ description: 'Maximum results (default 20)' }),
    },
    resolve: (_root, { query, limit }) => SearchQuery.search(query, limit ?? 20),
  }),
)
