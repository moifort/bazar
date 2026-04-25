import type { Brand } from 'ts-brand'
import type { ItemCategory } from '~/domain/item/types'
import type { UserId } from '~/domain/shared/types'

export type PreviewId = Brand<string, 'PreviewId'>

export type ItemPreview = {
  previewId: PreviewId
  name: string
  category: ItemCategory | null
  description: string
  quantity: number
}

export type ScanResult = {
  previewId: PreviewId
  userId: UserId
  previews: ItemPreview[]
  createdAt: Date
}
