import type { Brand } from 'ts-brand'
import type { UserId } from '~/domain/shared/types'

export type NotificationToken = Brand<string, 'NotificationToken'>
export type NotificationPlatform = 'ios'

export type NotificationSubscription = {
  token: NotificationToken
  userId: UserId
  platform: NotificationPlatform
  createdAt: Date
  updatedAt: Date
}
