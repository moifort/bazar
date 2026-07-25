import type {
  DocumentData,
  DocumentReference,
  FirestoreDataConverter,
  QueryDocumentSnapshot,
  Transaction,
} from 'firebase-admin/firestore'
import { chunk } from 'lodash-es'
import { db } from '~/system/firebase'

// Firestore caps a write batch at 500 operations, so an erasure of unknown size
// is committed in slices rather than in one batch that would fail past the cap.
const BATCH_LIMIT = 500

export const deleteInBatches = async (refs: DocumentReference[]): Promise<void> => {
  for (const slice of chunk(refs, BATCH_LIMIT)) {
    const batch = db().batch()
    for (const ref of slice) batch.delete(ref)
    await batch.commit()
  }
}

// An absent field is not a stored `null`: dropping the key is how the domain's
// "no value" survives a full `set`, which would otherwise write `undefined`.
export const withoutAbsentFields = <T extends DocumentData>(data: T): T =>
  Object.fromEntries(Object.entries(data).filter(([, value]) => value !== undefined)) as T

// Read-modify-write under Firestore's own optimistic locking. A counter read
// outside the transaction and written inside is exactly how two concurrent calls
// both record "one spent" and only one lands.
export const transactionally = <T>(run: (tx: Transaction) => Promise<T>): Promise<T> =>
  db().runTransaction(run)

export const genericDataConverter = <T extends DocumentData>(): FirestoreDataConverter<T> => ({
  toFirestore: (data: T) => data,
  fromFirestore: (snapshot: QueryDocumentSnapshot) => toDate(snapshot.data()) as T,
})

const toDate = (value: unknown): unknown => {
  if (!value || typeof value !== 'object') return value
  const obj = value as Record<string, unknown>
  for (const key of Object.keys(obj)) {
    const v = obj[key] as { toDate?: () => Date } | unknown
    if (v && typeof v === 'object' && typeof (v as { toDate?: unknown }).toDate === 'function') {
      obj[key] = (v as { toDate: () => Date }).toDate()
    } else if (v && typeof v === 'object') {
      toDate(v)
    }
  }
  return obj
}
