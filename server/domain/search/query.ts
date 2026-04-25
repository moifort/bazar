import type { UserId } from '~/domain/shared/types'
import { searchEntries } from './business-rules'
import { buildEntries } from './index'

const search = async (userId: UserId, query: string, limit = 20) => {
  const entries = await buildEntries(userId)
  return searchEntries(entries, query, limit)
}

export const SearchQuery = { search }
