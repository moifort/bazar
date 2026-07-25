import { freshQuota } from '~/domain/quota/business-rules'
import type { Quota, QuotaMonth } from '~/domain/quota/types'
import type { UserId } from '~/domain/shared/types'
import { db } from '~/system/firebase'
import { evictFromRequestCache, memoizedPerRequest } from '~/system/request-cache'
import { deleteInBatches, genericDataConverter, transactionally } from '~/utils/firestore'

const quotas = () => db().collection('scan-quotas').withConverter(genericDataConverter<Quota>())

// One document per user and per month, keyed deterministically: a month's quota
// is read by key, never by query, and last month's document is simply never read
// again — no purge, no scheduled job.
const quotaDocId = (userId: UserId, month: QuotaMonth) => `${userId}_${month}`

const cacheKey = (userId: UserId, month: QuotaMonth) => `quota:${userId}:${month}`

// Memoized for the request: the mutation checks the quota before calling the AI
// and records it after, and both must share the same single read.
export const findBy = (userId: UserId, month: QuotaMonth): Promise<Quota> =>
  memoizedPerRequest(cacheKey(userId, month), async () => {
    const doc = await quotas().doc(quotaDocId(userId, month)).get()
    // An absent document is a month nobody has scanned in — the storage boundary
    // defaults it rather than making every caller handle absence.
    return doc.data() ?? freshQuota(userId, month)
  })

// A whole window of months, in the order asked for. One keyed batch read: twelve
// document gets, no collection scan and no index.
export const findWindow = async (userId: UserId, months: QuotaMonth[]): Promise<Quota[]> => {
  if (months.length === 0) return []
  const refs = months.map((month) => quotas().doc(quotaDocId(userId, month)))
  const docs = await db().getAll(...refs)
  return docs.map((doc, index) => {
    const month = months[index] as QuotaMonth
    return (doc.data() as Quota | undefined) ?? freshQuota(userId, month)
  })
}

// Spend against the month's counter, atomically. The read has to happen inside
// the transaction — the memoized one is the pre-call value the caller already
// checked the limit against, and reusing it is exactly how two scans landing
// together would both write "one spent" and record only one.
export const consume = async (
  userId: UserId,
  month: QuotaMonth,
  spend: (quota: Quota) => Quota,
): Promise<Quota> => {
  const ref = quotas().doc(quotaDocId(userId, month))
  const spent = await transactionally(async (tx) => {
    const doc = await tx.get(ref)
    // Same storage boundary as `findBy`: an absent document is a fresh month.
    const spent = spend((doc.data() as Quota | undefined) ?? freshQuota(userId, month))
    tx.set(ref, spent)
    return spent
  })
  evictFromRequestCache(cacheKey(userId, month))
  return spent
}

// Every month this user has ever scanned in. Queried rather than derived: the
// documents are keyed by month, and nothing records which months exist.
export const removeAllByUser = async (userId: UserId): Promise<void> => {
  const snap = await quotas().where('userId', '==', userId).get()
  await deleteInBatches(snap.docs.map((doc) => doc.ref))
  for (const doc of snap.docs) evictFromRequestCache(cacheKey(userId, doc.data().month))
}
