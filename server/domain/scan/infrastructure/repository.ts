import { db } from '~/system/firebase'
import { genericDataConverter } from '~/utils/firestore'
import type { PreviewId, ScanResult } from '../types'

const scans = () => db().collection('scan-cache').withConverter(genericDataConverter<ScanResult>())

export const findBy = async (id: PreviewId): Promise<ScanResult | null> => {
  const snap = await scans().doc(id).get()
  return snap.data() ?? null
}

export const save = async (result: ScanResult): Promise<ScanResult> => {
  await scans().doc(result.previewId).set(result)
  return result
}

export const remove = async (id: PreviewId): Promise<void> => {
  await scans().doc(id).delete()
}
