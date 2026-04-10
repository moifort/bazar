import type { Item } from './types'

export type ItemEvent =
  | { type: 'item-added'; item: Item }
  | { type: 'item-updated'; item: Item }
  | { type: 'item-removed'; itemId: string }
  | { type: 'item-moved'; item: Item }
