import type { UserId } from '~/domain/shared/types'
import type { User } from '~/domain/user/types'
import { db } from '~/system/firebase'
import { evictFromRequestCache, memoizedPerRequest } from '~/system/request-cache'
import { genericDataConverter, withoutAbsentFields } from '~/utils/firestore'

const users = () => db().collection('users').withConverter(genericDataConverter<User>())

const cacheKey = (userId: UserId) => `user:${userId}`

// Keyed by user: one document each, so one read by key and no query. Memoized
// because every launch reads it to decide whether the onboarding is due, and the
// dashboard reads it again in the same request to say hello.
export const findBy = (userId: UserId): Promise<User | undefined> =>
  memoizedPerRequest(cacheKey(userId), async () => {
    const doc = await users().doc(userId).get()
    return doc.data()
  })

export const save = async (user: User): Promise<User> => {
  await users().doc(user.id).set(withoutAbsentFields(user))
  evictFromRequestCache(cacheKey(user.id))
  return user
}

export const removeBy = async (userId: UserId): Promise<void> => {
  await users().doc(userId).delete()
  evictFromRequestCache(cacheKey(userId))
}
