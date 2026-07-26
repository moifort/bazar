import { beforeEach, describe, expect, mock, test } from 'bun:test'
import { graphql } from 'graphql'
import type { UserId } from '~/domain/shared/types'
import { fakeFirebase, resetFakeFirestore } from '~/test/fake-firestore'

mock.module('~/system/firebase', fakeFirebase)

const { schema } = await import('~/domain/shared/graphql/schema')
const { createLoaders } = await import('~/domain/shared/graphql/loaders')

const userId = 'user-1' as UserId

let fake = resetFakeFirestore()
beforeEach(() => {
  fake = resetFakeFirestore()
})

const execute = (source: string) =>
  graphql({
    schema,
    source,
    contextValue: { userId, event: undefined as never, loaders: createLoaders(userId) },
  })

const completeOnboarding = `
  mutation {
    completeOnboarding(input: {
      firstName: "Thibaut"
      houseName: "Maison"
      houseIcon: "🏠"
      rooms: [{ name: "Cuisine", icon: "🍳" }]
    }) {
      firstName
    }
  }
`

describe('me query', () => {
  test('answers null while the onboarding has not run', async () => {
    const result = await execute('query { me { firstName } }')

    expect(result.errors).toBeUndefined()
    expect(result.data?.me).toBeNull()
  })

  test('answers the name once the onboarding has run', async () => {
    await execute(completeOnboarding)

    const result = await execute('query { me { firstName } }')
    expect(result.errors).toBeUndefined()
    expect(result.data?.me).toEqual({ firstName: 'Thibaut' })
  })
})

describe('completeOnboarding mutation', () => {
  test('creates the user, the house and its rooms', async () => {
    const result = await execute(completeOnboarding)

    expect(result.errors).toBeUndefined()
    expect(result.data?.completeOnboarding).toEqual({ firstName: 'Thibaut' })
    expect([...fake.snapshot('places').values()]).toMatchObject([{ name: 'Maison', icon: '🏠' }])
    expect([...fake.snapshot('rooms').values()]).toMatchObject([{ name: 'Cuisine', icon: '🍳' }])
  })

  test('answers ALREADY_ONBOARDED on a second run', async () => {
    await execute(completeOnboarding)

    const result = await execute(completeOnboarding)
    expect(result.errors?.[0]?.extensions?.code).toBe('ALREADY_ONBOARDED')
    expect(fake.snapshot('places').size).toBe(1)
  })

  test('refuses an empty first name at the boundary', async () => {
    const result = await execute(
      'mutation { completeOnboarding(input: { firstName: "  ", rooms: [] }) { firstName } }',
    )

    expect(result.errors?.[0]?.extensions?.code).toBe('BAD_USER_INPUT')
    expect(fake.snapshot('users').size).toBe(0)
  })
})
