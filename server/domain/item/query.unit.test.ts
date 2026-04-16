import { describe, expect, test } from 'bun:test'
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
