import type { UserId } from '~/domain/shared/types'
import * as repository from '~/domain/user/infrastructure/repository'
import { FirstName } from '~/domain/user/primitives'
import type { User } from '~/domain/user/types'

export namespace UserCommand {
  // Write down who the account belongs to, once. A user who already introduced
  // themselves is refused rather than overwritten: the onboarding also creates a
  // house, and a second run would hand them a duplicate of it.
  export const register = async (
    userId: UserId,
    firstName: string,
  ): Promise<User | 'already-onboarded'> => {
    const existing = await repository.findBy(userId)
    if (existing) return 'already-onboarded' as const
    return repository.save({
      id: userId,
      firstName: FirstName(firstName),
      onboardedAt: new Date(),
    })
  }

  // Everything this domain holds on one user, erased — the name they gave us and
  // the fact they ever came.
  export const forget = (userId: UserId): Promise<void> => repository.removeBy(userId)
}
