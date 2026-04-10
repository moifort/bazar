import type { Brand } from 'ts-brand'

export type ImageId = Brand<string, 'ImageId'>

export type Image = {
  id: ImageId
  data: string
  mimeType: string
  createdAt: Date
}
