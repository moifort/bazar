import { beforeEach, describe, expect, mock, test } from 'bun:test'
import type { UserId } from '~/domain/shared/types'
import { fakeFirebase, resetFakeFirestore } from '~/test/fake-firestore'

mock.module('~/system/firebase', fakeFirebase)

const { UserUseCase } = await import('~/domain/user/use-case')
const { UserQuery } = await import('~/domain/user/query')

const userId = 'user-1' as UserId

const onboarding = {
  firstName: 'Thibaut',
  house: { name: 'Maison', icon: '🏠' },
  rooms: [
    { name: 'Cuisine', icon: '🍳' },
    { name: 'Salon', icon: '🛋️' },
  ],
}

let fake = resetFakeFirestore()
beforeEach(() => {
  fake = resetFakeFirestore()
})

describe('UserUseCase.onboard', () => {
  test('records the first name, the house and its rooms in one go', async () => {
    const user = await UserUseCase.onboard(userId, onboarding)
    if (typeof user === 'string') throw new Error('expected a user')

    expect(user.firstName as string).toBe('Thibaut')
    expect(fake.snapshot('users').get(userId)).toMatchObject({ firstName: 'Thibaut' })

    const places = [...fake.snapshot('places').values()]
    expect(places).toMatchObject([{ userId, name: 'Maison', icon: '🏠', order: 0 }])

    const rooms = [...fake.snapshot('rooms').values()]
    expect(rooms).toMatchObject([
      { name: 'Cuisine', icon: '🍳', placeId: places[0]?.id, order: 0 },
      { name: 'Salon', icon: '🛋️', placeId: places[0]?.id, order: 1 },
    ])
  })

  test('ranks the rooms in the order they were picked', async () => {
    await UserUseCase.onboard(userId, {
      firstName: 'Thibaut',
      house: { name: 'Maison' },
      rooms: [{ name: 'Cuisine' }, { name: 'Salon' }, { name: 'Garage' }],
    })

    const rooms = [...fake.snapshot('rooms').values()].map((room) => [room.name, room.order])
    expect(rooms).toEqual([
      ['Cuisine', 0],
      ['Salon', 1],
      ['Garage', 2],
    ])
  })

  test('records the first name alone for an account that already owns places', async () => {
    await UserUseCase.onboard(userId, { firstName: 'Thibaut', rooms: [{ name: 'Cuisine' }] })

    expect(await UserQuery.of(userId)).toMatchObject({ firstName: 'Thibaut' })
    expect(fake.snapshot('places').size).toBe(0)
    expect(fake.snapshot('rooms').size).toBe(0)
  })

  test('refuses a second run rather than handing out a second house', async () => {
    await UserUseCase.onboard(userId, onboarding)

    expect(await UserUseCase.onboard(userId, onboarding)).toBe('already-onboarded')
    expect(fake.snapshot('places').size).toBe(1)
    expect(fake.snapshot('rooms').size).toBe(2)
  })

  test('leaves the user unknown until the onboarding runs', async () => {
    expect(await UserQuery.of(userId)).toBeUndefined()
  })
})
