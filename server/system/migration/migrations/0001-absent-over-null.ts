import { FieldValue } from 'firebase-admin/firestore'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

// The domain models absence as a missing field, never as `null`. Documents
// written before that rule carry explicit nulls, which read back as a present
// field holding null — so `field ?? fallback` works but `'field' in data` lies,
// and Firestore's orderBy sorts them ahead of everything else. Drop them.
const NULLABLE_FIELDS: Record<string, string[]> = {
  items: [
    'storageId',
    'zoneId',
    'placeId',
    'purchaseDate',
    'purchaseCondition',
    'lowStockThreshold',
  ],
  reminders: ['frequency', 'customIntervalDays'],
  places: ['icon'],
  rooms: ['icon'],
}

// Firestore caps a batch at 500 writes.
const BATCH_SIZE = 400

export const migration0001: Migration = {
  version: MigrationVersion(1),
  name: MigrationName('absent-over-null'),
  migrate: async ({ db }) => {
    let transformed = 0

    for (const [collection, fields] of Object.entries(NULLABLE_FIELDS)) {
      const snap = await db.collection(collection).get()

      let batch = db.batch()
      let pending = 0

      for (const doc of snap.docs) {
        const data = doc.data()
        const toDrop = fields.filter((field) => data[field] === null)
        if (toDrop.length === 0) continue

        batch.update(
          doc.ref,
          Object.fromEntries(toDrop.map((field) => [field, FieldValue.delete()])),
        )
        transformed++
        pending++

        if (pending === BATCH_SIZE) {
          await batch.commit()
          batch = db.batch()
          pending = 0
        }
      }

      if (pending > 0) await batch.commit()
    }

    return { ok: true, transformed }
  },
}
