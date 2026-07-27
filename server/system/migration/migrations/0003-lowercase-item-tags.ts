import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'
import { normalizeText } from '~/utils/text'

// Tags are stored lowercased — case is not information, "Bosch" and "bosch"
// are the same keyword. Documents written between the field shipping and that
// rule still carry the AI's original casing, which reads back as a value the
// constructor would never produce. Lowercasing can also collide two keywords
// into one, so the list is deduplicated again, first occurrence winning, the
// way `parseItemTags` does it.
const lowercased = (tags: string[]) => {
  const seen = new Set<string>()
  return tags.reduce<string[]>((kept, tag) => {
    const value = tag.trim().toLowerCase()
    const key = normalizeText(value)
    if (value.length === 0 || seen.has(key)) return kept
    seen.add(key)
    kept.push(value)
    return kept
  }, [])
}

// Firestore caps a batch at 500 writes.
const BATCH_SIZE = 400

export const migration0003: Migration = {
  version: MigrationVersion(3),
  name: MigrationName('lowercase-item-tags'),
  migrate: async ({ db }) => {
    const snap = await db.collection('items').get()

    let transformed = 0
    let batch = db.batch()
    let pending = 0

    for (const doc of snap.docs) {
      const tags = doc.data().tags
      if (!Array.isArray(tags) || tags.length === 0) continue

      const cleaned = lowercased(tags)
      if (cleaned.length === tags.length && cleaned.every((tag, i) => tag === tags[i])) continue

      batch.update(doc.ref, { tags: cleaned })
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
