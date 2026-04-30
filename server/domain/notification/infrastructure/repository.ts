import { createHash } from 'node:crypto'
import type { UserId } from '~/domain/shared/types'
import { db } from '~/system/firebase'
import { genericDataConverter } from '~/utils/firestore'
import type { NotificationSubscription, NotificationToken } from '../types'

const subscriptions = () =>
  db()
    .collection('notification-subscriptions')
    .withConverter(genericDataConverter<NotificationSubscription>())

const docId = (token: NotificationToken) => createHash('sha256').update(token).digest('hex')

export const findByUser = async (userId: UserId): Promise<NotificationSubscription[]> => {
  const snap = await subscriptions().where('userId', '==', userId).get()
  return snap.docs.map((doc) => doc.data())
}

export const save = async (
  subscription: NotificationSubscription,
): Promise<NotificationSubscription> => {
  await subscriptions().doc(docId(subscription.token)).set(subscription)
  return subscription
}

export const removeByToken = async (token: NotificationToken): Promise<void> => {
  await subscriptions().doc(docId(token)).delete()
}
