import { consumed, monthOf } from '~/domain/quota/business-rules'
import * as repository from '~/domain/quota/infrastructure/repository'
import type { Quota } from '~/domain/quota/types'
import type { UserId } from '~/domain/shared/types'

export namespace QuotaCommand {
  // Write down one scan that actually happened. Called AFTER the AI answered,
  // never before: a Gemini failure must not cost the user a scan, and a refused
  // request never reaches this point. The increment reads and writes in one
  // transaction — two scans finishing together must count two, and a plain
  // read-then-set counted one.
  export const record = async (userId: UserId): Promise<Quota> =>
    repository.consume(userId, monthOf(new Date()), consumed)

  // Everything this domain holds on one user, erased. Called only when the
  // account itself goes: there is no other reason to forget what the AI cost.
  export const forget = (userId: UserId): Promise<void> => repository.removeAllByUser(userId)
}
