import type { UserId } from '~/domain/shared/types'
import { sendLowStockPush } from './infrastructure/fcm'
import * as repository from './infrastructure/repository'
import { NotificationToken, parseNotificationPlatform } from './primitives'
import type { NotificationPlatform, NotificationSubscription } from './types'

type SubscribeInput = {
  userId: UserId
  token: string
  platform: NotificationPlatform | string
}

const subscribe = async ({ userId, token, platform }: SubscribeInput) => {
  const validatedToken = NotificationToken(token)
  const subscription: NotificationSubscription = {
    token: validatedToken,
    userId,
    platform: parseNotificationPlatform(platform),
    createdAt: new Date(),
    updatedAt: new Date(),
  }
  await repository.save(subscription)
  return subscription
}

const unsubscribe = async (token: string) => {
  const validatedToken = NotificationToken(token)
  await repository.removeByToken(validatedToken)
}

type DispatchLowStockInput = {
  userId: UserId
  itemName: string
  newQuantity: number
}

const dispatchLowStock = async ({ userId, itemName, newQuantity }: DispatchLowStockInput) => {
  const subs = await repository.findByUser(userId)
  if (subs.length === 0) return
  const tokens = subs.map((s) => s.token)
  const invalidTokens = await sendLowStockPush({ tokens, itemName, newQuantity })
  await Promise.all(invalidTokens.map((token) => repository.removeByToken(token)))
}

const forget = (userId: UserId): Promise<void> => repository.removeAllByUser(userId)

export const NotificationCommand = { subscribe, unsubscribe, dispatchLowStock, forget }
