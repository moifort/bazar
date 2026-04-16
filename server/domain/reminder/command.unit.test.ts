import { describe, expect, test } from 'bun:test'
import { randomUUID } from 'node:crypto'
import { ItemCommand } from '~/domain/item/command'
import { ReminderCommand } from './command'
import { ReminderQuery } from './query'

const makeItem = async () => {
  const item = await ItemCommand.add({
    name: 'Cafetière',
    category: 'appliances',
    addedBy: 'tester',
  })
  return item
}

describe('ReminderCommand.add', () => {
  test('creates a ponctual reminder for an existing item', async () => {
    const item = await makeItem()
    const result = await ReminderCommand.add({
      itemId: item.id,
      title: 'Détartrer',
      dueDate: new Date('2026-07-01T10:00:00.000Z'),
    })
    expect(result).toMatchObject({ tag: 'added' })
    if (result === 'item-not-found') throw new Error('unexpected')
    expect(result.reminder.itemId).toBe(item.id)
    expect(result.reminder.frequency).toBeNull()
    expect(result.reminder.customIntervalDays).toBeNull()
  })

  test('creates a recurring reminder', async () => {
    const item = await makeItem()
    const result = await ReminderCommand.add({
      itemId: item.id,
      title: 'Détartrer',
      dueDate: new Date('2026-07-01T10:00:00.000Z'),
      frequency: 'quarterly',
    })
    if (result === 'item-not-found') throw new Error('unexpected')
    expect(result.reminder.frequency).toBe('quarterly')
  })

  test('creates a custom-days reminder with interval', async () => {
    const item = await makeItem()
    const result = await ReminderCommand.add({
      itemId: item.id,
      title: 'Arroser',
      dueDate: new Date('2026-07-01T10:00:00.000Z'),
      frequency: 'custom-days',
      customIntervalDays: 14,
    })
    if (result === 'item-not-found') throw new Error('unexpected')
    expect(result.reminder.frequency).toBe('custom-days')
    expect(result.reminder.customIntervalDays).toBe(14)
  })

  test('returns item-not-found when the item does not exist', async () => {
    const result = await ReminderCommand.add({
      itemId: randomUUID(),
      title: 'X',
      dueDate: new Date(),
    })
    expect(result).toBe('item-not-found')
  })

  test('rejects custom-days without customIntervalDays', async () => {
    const item = await makeItem()
    await expect(
      ReminderCommand.add({
        itemId: item.id,
        title: 'X',
        dueDate: new Date(),
        frequency: 'custom-days',
      }),
    ).rejects.toThrow()
  })

  test('rejects non-custom frequency with customIntervalDays', async () => {
    const item = await makeItem()
    await expect(
      ReminderCommand.add({
        itemId: item.id,
        title: 'X',
        dueDate: new Date(),
        frequency: 'monthly',
        customIntervalDays: 10,
      }),
    ).rejects.toThrow()
  })
})

describe('ReminderCommand.complete', () => {
  test('reschedules a recurring reminder and logs a completion', async () => {
    const item = await makeItem()
    const added = await ReminderCommand.add({
      itemId: item.id,
      title: 'Détartrer',
      dueDate: new Date('2026-07-01T10:00:00.000Z'),
      frequency: 'quarterly',
    })
    if (added === 'item-not-found') throw new Error('unexpected')

    const completedAt = new Date('2026-06-20T10:00:00.000Z')
    const result = await ReminderCommand.complete(added.reminder.id, completedAt)
    if (result === 'not-found') throw new Error('unexpected')
    expect(result.tag).toBe('rescheduled')
    if (result.tag !== 'rescheduled') throw new Error('unexpected')
    expect(result.reminder.dueDate.toISOString()).toBe('2026-10-01T10:00:00.000Z')

    const completions = await ReminderQuery.completionsByReminder(added.reminder.id)
    expect(completions).toHaveLength(1)
    expect(completions[0].completedAt.toISOString()).toBe(completedAt.toISOString())
  })

  test('deletes a ponctual reminder and logs a completion', async () => {
    const item = await makeItem()
    const added = await ReminderCommand.add({
      itemId: item.id,
      title: 'Renvoyer',
      dueDate: new Date('2026-07-01T10:00:00.000Z'),
    })
    if (added === 'item-not-found') throw new Error('unexpected')

    const result = await ReminderCommand.complete(added.reminder.id)
    if (result === 'not-found') throw new Error('unexpected')
    expect(result.tag).toBe('done')

    const stillThere = await ReminderQuery.byId(added.reminder.id)
    expect(stillThere).toBeNull()

    const completions = await ReminderQuery.completionsByReminder(added.reminder.id)
    expect(completions).toHaveLength(1)
  })

  test('completing recurring 3 times keeps 3 completions and advances 3 times', async () => {
    const item = await makeItem()
    const added = await ReminderCommand.add({
      itemId: item.id,
      title: 'Nettoyer',
      dueDate: new Date('2026-07-01T10:00:00.000Z'),
      frequency: 'monthly',
    })
    if (added === 'item-not-found') throw new Error('unexpected')

    const t1 = new Date('2026-06-25T10:00:00.000Z')
    const t2 = new Date('2026-07-30T10:00:00.000Z')
    const t3 = new Date('2026-08-30T10:00:00.000Z')
    await ReminderCommand.complete(added.reminder.id, t1)
    await ReminderCommand.complete(added.reminder.id, t2)
    const third = await ReminderCommand.complete(added.reminder.id, t3)
    if (third === 'not-found' || third.tag !== 'rescheduled') throw new Error('unexpected')

    const completions = await ReminderQuery.completionsByReminder(added.reminder.id)
    expect(completions).toHaveLength(3)
  })
})

describe('ReminderCommand.update', () => {
  test('updates title and dueDate', async () => {
    const item = await makeItem()
    const added = await ReminderCommand.add({
      itemId: item.id,
      title: 'Old',
      dueDate: new Date('2026-07-01T10:00:00.000Z'),
    })
    if (added === 'item-not-found') throw new Error('unexpected')

    const updated = await ReminderCommand.update(added.reminder.id, {
      title: 'New',
      dueDate: new Date('2026-08-01T10:00:00.000Z'),
    })
    if (updated === 'not-found') throw new Error('unexpected')
    expect(updated.reminder.title).toBe('New' as never)
    expect(updated.reminder.dueDate.toISOString()).toBe('2026-08-01T10:00:00.000Z')
  })

  test('clears frequency when set to null', async () => {
    const item = await makeItem()
    const added = await ReminderCommand.add({
      itemId: item.id,
      title: 'T',
      dueDate: new Date('2026-07-01T10:00:00.000Z'),
      frequency: 'custom-days',
      customIntervalDays: 7,
    })
    if (added === 'item-not-found') throw new Error('unexpected')

    const updated = await ReminderCommand.update(added.reminder.id, {
      frequency: null,
      customIntervalDays: null,
    })
    if (updated === 'not-found') throw new Error('unexpected')
    expect(updated.reminder.frequency).toBeNull()
    expect(updated.reminder.customIntervalDays).toBeNull()
  })
})

describe('ReminderCommand.removeByItem', () => {
  test('removes all reminders attached to the item', async () => {
    const itemA = await makeItem()
    const itemB = await makeItem()
    await ReminderCommand.add({ itemId: itemA.id, title: 'A1', dueDate: new Date() })
    await ReminderCommand.add({ itemId: itemA.id, title: 'A2', dueDate: new Date() })
    await ReminderCommand.add({ itemId: itemB.id, title: 'B1', dueDate: new Date() })

    await ReminderCommand.removeByItem(itemA.id)

    expect(await ReminderQuery.byItem(itemA.id)).toHaveLength(0)
    expect(await ReminderQuery.byItem(itemB.id)).toHaveLength(1)
  })
})
