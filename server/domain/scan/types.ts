import type { Brand } from 'ts-brand'
import type { ItemCategory } from '~/domain/item/types'
import type { UserId } from '~/domain/shared/types'

export type PreviewId = Brand<string, 'PreviewId'>

export type ItemPreview = {
  previewId: PreviewId
  name: string
  category?: ItemCategory
  description: string
  /** Raw keywords suggested by the AI. They are only branded once the batch is
   * confirmed — until then nothing here is an item's data. */
  tags: string[]
  quantity: number
}

export type ScanResult = {
  previewId: PreviewId
  userId: UserId
  previews: ItemPreview[]
  createdAt: Date
}
