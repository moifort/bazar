import { searchEntries } from './business-rules'
import { getEntries } from './index'

const search = (query: string, limit = 20) => searchEntries(getEntries(), query, limit)

export const SearchQuery = { search }
