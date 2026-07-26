import type { UserId } from '~/domain/shared/types'
import * as repository from '~/domain/user/infrastructure/repository'
import type { User } from '~/domain/user/types'

export namespace UserQuery {
  // Who this account belongs to, if they ever said. Absent is the state of every
  // account that has not been through the onboarding — the app reads it to know
  // whether to run it.
  export const of = async (userId: UserId): Promise<User | undefined> => repository.findBy(userId)
}
