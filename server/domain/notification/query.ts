import type { UserId } from '~/domain/shared/types'
import * as repository from './infrastructure/repository'
import type { NotificationSubscription } from './types'

const subscriptionsByUserId = async (userId: UserId): Promise<NotificationSubscription[]> =>
  repository.findByUser(userId)

export const NotificationQuery = { subscriptionsByUserId }
