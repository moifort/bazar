import { beforeEach, describe, expect, test } from 'bun:test'
import { resetFakeFirestore } from '~/test/fake-firestore'
import { migration0002 } from './0002-item-tags'

let fake = resetFakeFirestore()

describe('migration 0002 — item tags', () => {
  beforeEach(() => {
    fake = resetFakeFirestore()
  })

  test('gives an item written before the field an empty tag list', async () => {
    fake.seed('items', 'i1', { id: 'i1', name: 'Perceuse' })

    const result = await migration0002.migrate({ db: fake.db })

    expect(result).toEqual({ ok: true, transformed: 1 })
    expect(fake.snapshot('items').get('i1')).toEqual({ id: 'i1', name: 'Perceuse', tags: [] })
  })

  test('leaves the tags an item already carries alone', async () => {
    fake.seed('items', 'i1', { id: 'i1', tags: ['cumin', 'condiment'] })

    const result = await migration0002.migrate({ db: fake.db })

    expect(result).toEqual({ ok: true, transformed: 0 })
    expect(fake.snapshot('items').get('i1')).toEqual({ id: 'i1', tags: ['cumin', 'condiment'] })
    // No document rewritten means no batch committed at all.
    expect(fake.batches.every((batch) => batch.commits === 0)).toBe(true)
  })

  test('is idempotent — a second run finds nothing left to fill', async () => {
    fake.seed('items', 'i1', { id: 'i1' })

    await migration0002.migrate({ db: fake.db })
    const second = await migration0002.migrate({ db: fake.db })

    expect(second).toEqual({ ok: true, transformed: 0 })
  })

  test('writes through batches, never one round-trip per document', async () => {
    for (let i = 0; i < 10; i++) fake.seed('items', `i${i}`, { id: `i${i}` })

    await migration0002.migrate({ db: fake.db })

    expect(fake.directWrites).toHaveLength(0)
    const committed = fake.batches.filter((batch) => batch.commits > 0)
    expect(committed).toHaveLength(1)
    expect(committed[0].ops).toHaveLength(10)
  })
})
