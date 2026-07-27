import { beforeEach, describe, expect, test } from 'bun:test'
import { resetFakeFirestore } from '~/test/fake-firestore'
import { migration0003 } from './0003-lowercase-item-tags'

let fake = resetFakeFirestore()

describe('migration 0003 — lowercase item tags', () => {
  beforeEach(() => {
    fake = resetFakeFirestore()
  })

  test('lowercases the keywords written before the rule', async () => {
    fake.seed('items', 'i1', { id: 'i1', tags: ['Bosch', 'Visseuse', '18V'] })

    const result = await migration0003.migrate({ db: fake.db })

    expect(result).toEqual({ ok: true, transformed: 1 })
    expect(fake.snapshot('items').get('i1')).toEqual({
      id: 'i1',
      tags: ['bosch', 'visseuse', '18v'],
    })
  })

  test('merges the keywords lowercasing collides, first occurrence winning', async () => {
    fake.seed('items', 'i1', { id: 'i1', tags: ['Épice', 'epice', 'CUMIN', 'cumin'] })

    await migration0003.migrate({ db: fake.db })

    expect(fake.snapshot('items').get('i1')).toEqual({ id: 'i1', tags: ['épice', 'cumin'] })
  })

  test('leaves an already-lowercase list alone', async () => {
    fake.seed('items', 'i1', { id: 'i1', tags: ['cumin', 'paprika'] })
    fake.seed('items', 'i2', { id: 'i2', tags: [] })

    const result = await migration0003.migrate({ db: fake.db })

    expect(result).toEqual({ ok: true, transformed: 0 })
    // No document rewritten means no batch committed at all.
    expect(fake.batches.every((batch) => batch.commits === 0)).toBe(true)
  })

  test('is idempotent — a second run finds nothing left to lowercase', async () => {
    fake.seed('items', 'i1', { id: 'i1', tags: ['Bosch'] })

    await migration0003.migrate({ db: fake.db })
    const second = await migration0003.migrate({ db: fake.db })

    expect(second).toEqual({ ok: true, transformed: 0 })
  })

  test('writes through batches, never one round-trip per document', async () => {
    for (let i = 0; i < 10; i++) fake.seed('items', `i${i}`, { id: `i${i}`, tags: ['Bosch'] })

    await migration0003.migrate({ db: fake.db })

    expect(fake.directWrites).toHaveLength(0)
    const committed = fake.batches.filter((batch) => batch.commits > 0)
    expect(committed).toHaveLength(1)
    expect(committed[0].ops).toHaveLength(10)
  })
})
