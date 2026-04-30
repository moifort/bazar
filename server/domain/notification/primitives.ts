import { make } from 'ts-brand'
import { z } from 'zod'
import type { NotificationPlatform, NotificationToken as NotificationTokenType } from './types'

export const NotificationToken = (value: unknown) => {
  const v = z.string().min(1).max(4096).parse(value)
  return make<NotificationTokenType>()(v)
}

const platforms: NotificationPlatform[] = ['ios']

export const parseNotificationPlatform = (value: unknown): NotificationPlatform => {
  const v = z.string().parse(value)
  if (!platforms.includes(v as NotificationPlatform))
    throw new Error(`Invalid notification platform: ${v}`)
  return v as NotificationPlatform
}
