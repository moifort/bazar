import { beforeEach, describe, expect, mock, test } from 'bun:test'
import type { UserId } from '~/domain/shared/types'
import { deletedUsers, fakeFirebase, resetFakeFirestore } from '~/test/fake-firestore'

mock.module('~/system/firebase', fakeFirebase)

const { AccountUseCase } = await import('~/system/account/use-case')

const owner = 'user-1' as UserId
const other = 'user-2' as UserId

let fake = resetFakeFirestore()
beforeEach(() => {
  fake = resetFakeFirestore()

  fake.seed('items', 'i1', { id: 'i1', userId: owner, name: 'Casserole' })
  fake.seed('items', 'i2', { id: 'i2', userId: other, name: 'Poele' })
  fake.seed('places', 'p1', { id: 'p1', userId: owner, name: 'Appartement', order: 1 })
  fake.seed('rooms', 'ro1', { id: 'ro1', userId: owner, placeId: 'p1', name: 'Cuisine', order: 1 })
  fake.seed('zones', 'z1', { id: 'z1', userId: owner, roomId: 'ro1', name: 'Placard', order: 1 })
  fake.seed('storages', 's1', { id: 's1', userId: owner, zoneId: 'z1', name: 'Etagere', order: 1 })
  fake.seed('places', 'p2', { id: 'p2', userId: other, name: 'Maison', order: 1 })
  fake.seed('reminders', 'rem1', { id: 'rem1', userId: owner, itemId: 'i1', title: 'Detartrer' })
  fake.seed('reminder-completions', 'c1', { id: 'c1', userId: owner, reminderId: 'rem1' })
  fake.seed('reminders', 'rem2', { id: 'rem2', userId: other, itemId: 'i2', title: 'Nettoyer' })
  fake.seed('notification-subscriptions', 'n1', { userId: owner, token: 'token-1' })
  fake.seed('notification-subscriptions', 'n2', { userId: other, token: 'token-2' })
})

describe('AccountUseCase.remove', () => {
  test('erases the items', async () => {
    await AccountUseCase.remove(owner)

    expect([...fake.snapshot('items').keys()]).toEqual(['i2'])
  })

  test('erases the four levels of the location hierarchy', async () => {
    await AccountUseCase.remove(owner)

    expect([...fake.snapshot('places').keys()]).toEqual(['p2'])
    expect(fake.snapshot('rooms').size).toBe(0)
    expect(fake.snapshot('zones').size).toBe(0)
    expect(fake.snapshot('storages').size).toBe(0)
  })

  test('erases the reminders together with their completion history', async () => {
    await AccountUseCase.remove(owner)

    expect([...fake.snapshot('reminders').keys()]).toEqual(['rem2'])
    expect(fake.snapshot('reminder-completions').size).toBe(0)
  })

  test('erases every device registered for notifications', async () => {
    await AccountUseCase.remove(owner)

    expect([...fake.snapshot('notification-subscriptions').keys()]).toEqual(['n2'])
  })

  test('deletes the authentication account itself', async () => {
    await AccountUseCase.remove(owner)

    expect(deletedUsers).toEqual([owner])
  })

  test('deletes the account only after the data, never before', async () => {
    await AccountUseCase.remove(owner)

    // Nothing of this owner may outlive the account: were the order reversed, a
    // failure would strand documents keyed to a user nobody can authenticate as.
    expect(fake.snapshot('items').has('i1')).toBe(false)
    expect(fake.snapshot('places').has('p1')).toBe(false)
    expect(deletedUsers).toEqual([owner])
  })

  test('leaves every other user untouched', async () => {
    await AccountUseCase.remove(owner)

    expect(fake.snapshot('items').get('i2')).toMatchObject({ userId: other })
    expect(fake.snapshot('places').get('p2')).toMatchObject({ userId: other })
    expect(fake.snapshot('reminders').get('rem2')).toMatchObject({ userId: other })
    expect(deletedUsers).not.toContain(other)
  })
})
