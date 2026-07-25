import type { UserId } from '~/domain/shared/types'
import * as repository from './infrastructure/repository'
import { analyzePhoto } from './scanner'
import type { ScanResult } from './types'

export namespace ScanCommand {
  // Read a photo and cache what was recognised. The previews are not items yet:
  // nothing enters the inventory until the batch is confirmed.
  export const analyze = async (userId: UserId, imageBase64: string): Promise<ScanResult> => {
    const result = await analyzePhoto(userId, imageBase64)
    await repository.save(result)
    return result
  }
}
