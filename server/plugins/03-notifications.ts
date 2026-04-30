import { subscribeNotificationHandlers } from '~/domain/notification/events'

export default defineNitroPlugin(() => {
  subscribeNotificationHandlers()
})
