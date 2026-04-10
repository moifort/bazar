import { randomUUID } from 'node:crypto'
import type { ItemCategory } from '~/domain/item/types'
import { createLogger } from '~/system/logger'
import { analyzeImage } from './infrastructure/gemini'
import { PreviewId } from './primitives'
import type { ItemPreview, ScanResult } from './types'

const log = createLogger('scanner')

export const analyzePhoto = async (imageBase64: string): Promise<ScanResult> => {
  log.info('Analyzing photo with Gemini 2.5 Flash')

  const items = await analyzeImage(imageBase64)

  const previews: ItemPreview[] = items.map((item) => ({
    previewId: PreviewId(randomUUID()),
    name: item.name,
    category: (item.category as ItemCategory) ?? null,
    description: item.description ?? '',
    quantity: item.quantity ?? 1,
  }))

  log.info(`Identified ${previews.length} item(s)`)

  return {
    previewId: PreviewId(randomUUID()),
    previews,
    imageBase64,
    createdAt: new Date(),
  }
}
