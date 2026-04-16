import { describe, expect, test } from 'bun:test'
import { ItemCommand } from '~/domain/item/command'
import { ReminderCommand } from './command'
import { ReminderQuery } from './query'

const makeItem = () =>
  ItemCommand.add({
    name: 'Item',
    category: 'other',
    addedBy: 'tester',
  })

describe('ReminderQuery.byItem', () => {
  test('returns only reminders of the requested item, sorted by dueDate asc', async () => {
    const itemA = await makeItem()
    const itemB = await makeItem()
    await ReminderCommand.add({
      itemId: itemA.id,
      title: 'Later',
      dueDate: new Date('2026-09-01T00:00:00.000Z'),
    })
    await ReminderCommand.add({
      itemId: itemA.id,
      title: 'Sooner',
      dueDate: new Date('2026-07-01T00:00:00.000Z'),
    })
    await ReminderCommand.add({
      itemId: itemB.id,
      title: 'Other',
      dueDate: new Date('2026-05-01T00:00:00.000Z'),
    })

    const result = await ReminderQuery.byItem(itemA.id)
    expect(result).toHaveLength(2)
    expect(result[0].title).toBe('Sooner' as never)
    expect(result[1].title).toBe('Later' as never)
  })
})

describe('ReminderQuery.remindersDue', () => {
  test('returns only reminders with dueDate <= before, sorted asc', async () => {
    const item = await makeItem()
    await ReminderCommand.add({
      itemId: item.id,
      title: 'Past',
      dueDate: new Date('2026-01-01T00:00:00.000Z'),
    })
    await ReminderCommand.add({
      itemId: item.id,
      title: 'Near',
      dueDate: new Date('2026-04-20T00:00:00.000Z'),
    })
    await ReminderCommand.add({
      itemId: item.id,
      title: 'Far',
      dueDate: new Date('2027-01-01T00:00:00.000Z'),
    })

    const before = new Date('2026-05-01T00:00:00.000Z')
    const result = await ReminderQuery.remindersDue(before)
    expect(result).toHaveLength(2)
    expect(result[0].title).toBe('Past' as never)
    expect(result[1].title).toBe('Near' as never)
  })
})
