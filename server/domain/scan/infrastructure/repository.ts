import { createTypedStorage } from '~/system/storage'
import type { ScanResult } from '../types'

const scanCacheStorage = () => createTypedStorage<ScanResult>('scan-cache')

export const findBy = (id: string) => scanCacheStorage().getItem(id)

export const save = (result: ScanResult) => scanCacheStorage().setItem(result.previewId, result)

export const remove = (id: string) => scanCacheStorage().removeItem(id)
