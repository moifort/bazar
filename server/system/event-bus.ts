import { createLogger } from '~/system/logger'

const log = createLogger('event-bus')

type EventHandler<T = unknown> = (event: T) => Promise<void>

const handlers = new Map<string, EventHandler[]>()

export const on = <T>(name: string, handler: EventHandler<T>) => {
  const existing = handlers.get(name) ?? []
  handlers.set(name, [...existing, handler as EventHandler])
}

export const emit = async <T>(name: string, event: T) => {
  const eventHandlers = handlers.get(name) ?? []
  log.info(`Emitting ${name}`, { handlerCount: eventHandlers.length })
  await Promise.all(eventHandlers.map((handler) => handler(event)))
}

export const clearHandlers = () => {
  handlers.clear()
}
