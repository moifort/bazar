import type { Brand } from 'ts-brand'
import type { ItemCategory } from '~/domain/item/types'

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
  previews: ItemPreview[]
  imageBase64: string
  createdAt: Date
}
