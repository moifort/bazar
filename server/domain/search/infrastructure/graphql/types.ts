import { builder } from '~/domain/shared/graphql/builder'
import type { SearchEntry } from '../../types'

export const SearchEntryType = builder.objectRef<SearchEntry>('SearchEntry').implement({
  description: 'A search result entry',
  fields: (t) => ({
    type: t.exposeString('type', { description: 'Entry type (item, place, room)' }),
    entityId: t.exposeString('entityId', { description: 'ID of the matched entity' }),
    text: t.exposeString('text', { description: 'Matched text content' }),
  }),
})
