import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

// An item now carries `tags`, the keywords it is searched by. The domain
// promises the array is always there and reads it without a fallback, so the
// documents written before the field existed get an empty one — an absent
// `tags` would read back as `undefined` and break the promise.

// Firestore caps a batch at 500 writes.
const BATCH_SIZE = 400

export const migration0002: Migration = {
  version: MigrationVersion(2),
  name: MigrationName('item-tags'),
  migrate: async ({ db }) => {
    const snap = await db.collection('items').get()

    let transformed = 0
    let batch = db.batch()
    let pending = 0

    for (const doc of snap.docs) {
      if (Array.isArray(doc.data().tags)) continue

      batch.update(doc.ref, { tags: [] })
      transformed++
      pending++

      if (pending === BATCH_SIZE) {
        await batch.commit()
        batch = db.batch()
        pending = 0
      }
    }

    if (pending > 0) await batch.commit()

    return { ok: true, transformed }
  },
}
