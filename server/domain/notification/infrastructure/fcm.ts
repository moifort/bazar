import { getMessaging } from 'firebase-admin/messaging'
import { createLogger } from '~/system/logger'
import type { NotificationToken } from '../types'

const log = createLogger('fcm')

type LowStockPayload = {
  tokens: NotificationToken[]
  itemName: string
  newQuantity: number
}

const INVALID_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-argument',
  'messaging/invalid-registration-token',
])

export const sendLowStockPush = async ({
  tokens,
  itemName,
  newQuantity,
}: LowStockPayload): Promise<NotificationToken[]> => {
  if (tokens.length === 0) return []

  const response = await getMessaging().sendEachForMulticast({
    tokens,
    notification: {
      title: 'Stock bas',
      body: `${itemName} — il en reste ${newQuantity}`,
    },
    apns: {
      headers: { 'apns-priority': '10' },
      payload: { aps: { category: 'LOW_STOCK', sound: 'default' } },
    },
  })

  type SendResponse = { success: boolean; error?: { code?: string; message?: string } }
  const invalidTokens: NotificationToken[] = []
  ;(response.responses as SendResponse[]).forEach((res, index) => {
    if (res.success) return
    const code = res.error?.code
    log.warn('FCM send failure', { code, message: res.error?.message })
    const token = tokens[index]
    if (token && code && INVALID_TOKEN_CODES.has(code)) invalidTokens.push(token)
  })

  return invalidTokens
}
