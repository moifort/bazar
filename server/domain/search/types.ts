export type SearchEntryType = 'item' | 'place' | 'room'

export type SearchEntry = {
  type: SearchEntryType
  entityId: string
  text: string
}
