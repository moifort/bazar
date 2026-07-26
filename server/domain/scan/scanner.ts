import { randomUUID } from 'node:crypto'
import type { ItemCategory } from '~/domain/item/types'
import type { UserId } from '~/domain/shared/types'
import { createLogger } from '~/system/logger'
import { withoutStorageUnits } from './business-rules'
import { analyzeImage } from './infrastructure/gemini'
import { PreviewId } from './primitives'
import type { ItemPreview, ScanResult } from './types'

const log = createLogger('scanner')

export const analyzePhoto = async (userId: UserId, imageBase64: string): Promise<ScanResult> => {
  log.info('Analyzing photo with Gemini 2.5 Flash')

  const items = await analyzeImage(imageBase64)

  const identified: ItemPreview[] = items.map((item) => ({
    previewId: PreviewId(randomUUID()),
    name: item.name,
    category: (item.category as ItemCategory) ?? null,
    description: item.description ?? '',
    quantity: item.quantity ?? 1,
  }))

  // The prompt already tells the model to leave the furniture out; this is the
  // deterministic half of the rule, the one that does not depend on its mood.
  const previews = withoutStorageUnits(identified)

  log.info(
    `Identified ${previews.length} item(s), dropped ${identified.length - previews.length} storage unit(s)`,
  )

  return {
    previewId: PreviewId(randomUUID()),
    userId,
    previews,
    createdAt: new Date(),
  }
}
