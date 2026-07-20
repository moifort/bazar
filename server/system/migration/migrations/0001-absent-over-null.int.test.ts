import { beforeEach, describe, expect, test } from 'bun:test'
import { resetFakeFirestore } from '~/test/fake-firestore'
import { migration0001 } from './0001-absent-over-null'

let fake = resetFakeFirestore()

describe('migration 0001 — absent over null', () => {
  beforeEach(() => {
    fake = resetFakeFirestore()
  })

  test('drops the null fields and leaves the values alone', async () => {
    fake.seed('items', 'i1', {
      id: 'i1',
      name: 'Perceuse',
      storageId: null,
      zoneId: 'zone-1',
      placeId: null,
      purchaseDate: null,
      purchaseCondition: null,
      lowStockThreshold: 3,
    })

    const result = await migration0001.migrate({ db: fake.db })

    expect(result).toEqual({ ok: true, transformed: 1 })
    const item = fake.snapshot('items').get('i1')
    expect(item).toEqual({
      id: 'i1',
      name: 'Perceuse',
      zoneId: 'zone-1',
      lowStockThreshold: 3,
    })
  })

  test('covers every collection that carried a nullable field', async () => {
    fake.seed('items', 'i1', { id: 'i1', placeId: null })
    fake.seed('reminders', 'r1', { id: 'r1', frequency: null, customIntervalDays: null })
    fake.seed('places', 'p1', { id: 'p1', icon: null })
    fake.seed('rooms', 'ro1', { id: 'ro1', icon: null })

    const result = await migration0001.migrate({ db: fake.db })

    expect(result).toEqual({ ok: true, transformed: 4 })
    expect(fake.snapshot('reminders').get('r1')).toEqual({ id: 'r1' })
    expect(fake.snapshot('places').get('p1')).toEqual({ id: 'p1' })
    expect(fake.snapshot('rooms').get('ro1')).toEqual({ id: 'ro1' })
  })

  test('leaves already-clean documents untouched', async () => {
    fake.seed('items', 'i1', { id: 'i1', zoneId: 'zone-1' })

    const result = await migration0001.migrate({ db: fake.db })

    expect(result).toEqual({ ok: true, transformed: 0 })
    // No document rewritten means no batch committed at all.
    expect(fake.batches.every((batch) => batch.commits === 0)).toBe(true)
  })

  test('is idempotent — a second run finds nothing left to drop', async () => {
    fake.seed('items', 'i1', { id: 'i1', storageId: null })

    await migration0001.migrate({ db: fake.db })
    const second = await migration0001.migrate({ db: fake.db })

    expect(second).toEqual({ ok: true, transformed: 0 })
  })

  test('writes through batches, never one round-trip per document', async () => {
    for (let i = 0; i < 10; i++) fake.seed('items', `i${i}`, { id: `i${i}`, placeId: null })

    await migration0001.migrate({ db: fake.db })

    expect(fake.directWrites).toHaveLength(0)
    const committed = fake.batches.filter((batch) => batch.commits > 0)
    expect(committed).toHaveLength(1)
    expect(committed[0].ops).toHaveLength(10)
  })
})
