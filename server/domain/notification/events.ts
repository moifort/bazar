import type { LowStockCrossedEvent } from '~/domain/item/events'
import { on } from '~/system/event-bus'
import { NotificationCommand } from './command'

export const subscribeNotificationHandlers = () => {
  on<LowStockCrossedEvent>('low-stock-crossed', async (event) => {
    await NotificationCommand.dispatchLowStock({
      userId: event.userId,
      itemName: event.name,
      newQuantity: event.newQuantity,
    })
  })
}
