import { describe, expect, test } from 'bun:test'
import { LocationCommand } from '~/domain/location/command'
import { ReminderCommand } from '~/domain/reminder/command'
import { ReminderQuery } from '~/domain/reminder/query'
import { ItemCommand } from './command'
import { ItemQuery } from './query'

const tinyBase64 =
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVORK5CYII='

const addItem = async (overrides: Partial<Parameters<typeof ItemCommand.add>[0]> = {}) =>
  ItemCommand.add({
    name: 'Item',
    category: 'other',
    addedBy: 'tester',
    ...overrides,
  })

describe('ItemQuery.distinctPurchaseLocations', () => {
  test('returns empty when no items have a purchase location', async () => {
    await addItem()
    await addItem()
    expect(await ItemQuery.distinctPurchaseLocations()).toEqual([])
  })

  test('ignores empty and whitespace-only values', async () => {
    await addItem({ purchaseLocation: '' })
    await addItem({ purchaseLocation: '   ' })
    await addItem({ purchaseLocation: 'Amazon' })
    expect(await ItemQuery.distinctPurchaseLocations()).toEqual(['Amazon'])
  })

  test('orders by frequency desc, then alphabetically', async () => {
    await addItem({ purchaseLocation: 'Amazon' })
    await addItem({ purchaseLocation: 'Amazon' })
    await addItem({ purchaseLocation: 'Leroy Merlin' })
    await addItem({ purchaseLocation: 'Leroy Merlin' })
    await addItem({ purchaseLocation: 'Castorama' })

    const result = await ItemQuery.distinctPurchaseLocations()
    expect(result).toEqual(['Amazon', 'Leroy Merlin', 'Castorama'])
  })

  test('is case-sensitive for distinct values (both preserved)', async () => {
    await addItem({ purchaseLocation: 'Amazon' })
    await addItem({ purchaseLocation: 'amazon' })
    const result = await ItemQuery.distinctPurchaseLocations()
    expect(result).toHaveLength(2)
    expect(result).toContain('Amazon')
    expect(result).toContain('amazon')
  })
})

describe('ItemCommand purchase fields', () => {
  test('add persists purchase metadata', async () => {
    const item = await addItem({
      purchaseDate: new Date('2026-03-01T00:00:00.000Z'),
      purchaseLocation: '  Amazon  ',
      invoiceImageBase64: tinyBase64,
    })
    expect(item.purchaseDate?.toISOString()).toBe('2026-03-01T00:00:00.000Z')
    expect(item.purchaseLocation).toBe('Amazon')
    expect(item.invoiceImageId).not.toBeNull()
  })

  test('update can clear purchaseDate', async () => {
    const item = await addItem({ purchaseDate: new Date('2026-03-01T00:00:00.000Z') })
    const result = await ItemCommand.update(item.id, { purchaseDate: null })
    if (result === 'not-found') throw new Error('unexpected')
    expect(result.item.purchaseDate).toBeNull()
  })

  test('update can replace the invoice image', async () => {
    const item = await addItem({ invoiceImageBase64: tinyBase64 })
    const firstInvoiceId = item.invoiceImageId
    const result = await ItemCommand.update(item.id, { invoiceImageBase64: tinyBase64 })
    if (result === 'not-found') throw new Error('unexpected')
    expect(result.item.invoiceImageId).not.toBeNull()
    expect(result.item.invoiceImageId).not.toBe(firstInvoiceId)
  })

  test('update can clear the invoice image with empty string', async () => {
    const item = await addItem({ invoiceImageBase64: tinyBase64 })
    const result = await ItemCommand.update(item.id, { invoiceImageBase64: '' })
    if (result === 'not-found') throw new Error('unexpected')
    expect(result.item.invoiceImageId).toBeNull()
  })
})

describe('ItemCommand.remove', () => {
  test('cascades deletion to attached reminders', async () => {
    const item = await addItem()
    await ReminderCommand.add({
      itemId: item.id,
      title: 'A',
      dueDate: new Date('2026-07-01T00:00:00.000Z'),
    })
    await ReminderCommand.add({
      itemId: item.id,
      title: 'B',
      dueDate: new Date('2026-08-01T00:00:00.000Z'),
      frequency: 'monthly',
    })

    await ItemCommand.remove(item.id)

    expect(await ReminderQuery.byItem(item.id)).toHaveLength(0)
  })
})

describe('ItemQuery.countByZone', () => {
  const setupZoneWithStorages = async (zoneName: string, storageNames: string[]) => {
    const place = await LocationCommand.createPlace({ name: `Maison-${zoneName}` })
    const roomResult = await LocationCommand.createRoom({
      placeId: place.id,
      name: `Room-${zoneName}`,
    })
    if (roomResult === 'place-not-found') throw new Error('unexpected place-not-found')
    const zoneResult = await LocationCommand.createZone({
      roomId: roomResult.room.id,
      name: zoneName,
    })
    if (zoneResult === 'room-not-found') throw new Error('unexpected room-not-found')
    const storages = await Promise.all(
      storageNames.map(async (name) => {
        const result = await LocationCommand.createStorage({
          zoneId: zoneResult.zone.id,
          name,
        })
        if (result === 'zone-not-found') throw new Error('unexpected zone-not-found')
        return result.storage
      }),
    )
    return { zone: zoneResult.zone, storages }
  }

  test('returns 0 when the zone has no storages', async () => {
    const { zone } = await setupZoneWithStorages('Empty', [])
    expect(await ItemQuery.countByZone(zone.id)).toBe(0)
  })

  test('returns 0 when storages exist but hold no items', async () => {
    const { zone } = await setupZoneWithStorages('Quiet', ['Etagere 1', 'Etagere 2'])
    expect(await ItemQuery.countByZone(zone.id)).toBe(0)
  })

  test('counts items across every storage of the zone', async () => {
    const { zone, storages } = await setupZoneWithStorages('Busy', ['A', 'B'])
    await addItem({ storageId: storages[0]?.id })
    await addItem({ storageId: storages[0]?.id })
    await addItem({ storageId: storages[1]?.id })
    expect(await ItemQuery.countByZone(zone.id)).toBe(3)
  })

  test('ignores items whose storage belongs to a different zone', async () => {
    const zoneA = await setupZoneWithStorages('ZoneA', ['SA'])
    const zoneB = await setupZoneWithStorages('ZoneB', ['SB'])
    await addItem({ storageId: zoneA.storages[0]?.id })
    await addItem({ storageId: zoneB.storages[0]?.id })
    await addItem({ storageId: zoneB.storages[0]?.id })

    expect(await ItemQuery.countByZone(zoneA.zone.id)).toBe(1)
    expect(await ItemQuery.countByZone(zoneB.zone.id)).toBe(2)
  })

  test('ignores items with no storage assigned', async () => {
    const { zone, storages } = await setupZoneWithStorages('Mixed', ['S'])
    await addItem({ storageId: storages[0]?.id })
    await addItem() // no storageId
    expect(await ItemQuery.countByZone(zone.id)).toBe(1)
  })
})
