import { afterEach, mock } from 'bun:test'
import { createStorage } from 'unstorage'
import memoryDriver from 'unstorage/drivers/memory'

const storages = new Map<string, ReturnType<typeof createStorage>>()

const getOrCreateStorage = (namespace: string) => {
  if (!storages.has(namespace)) {
    storages.set(namespace, createStorage({ driver: memoryDriver() }))
  }
  // biome-ignore lint/style/noNonNullAssertion: safe after has() check above
  return storages.get(namespace)!
}

const clearAllStores = async () => {
  await Promise.all([...storages.values()].map((storage) => storage.clear()))
  storages.clear()
}

// @ts-expect-error — global mock for Nitro's useStorage
globalThis.useStorage = (namespace: string) => getOrCreateStorage(namespace)

// @ts-expect-error — global mock for Nitro's defineEventHandler
globalThis.defineEventHandler = (handler: (...args: never[]) => unknown) => handler

// @ts-expect-error — global mock for Nitro's createError
globalThis.createError = (opts: { statusCode: number; statusMessage: string }) =>
  Object.assign(new Error(opts.statusMessage), opts)

// @ts-expect-error — global mock for h3's readBody
globalThis.readBody = (_event: MockEvent) => Promise.resolve(_event.__body)

// @ts-expect-error — global mock for h3's getQuery
globalThis.getQuery = (_event: MockEvent) => _event.__query ?? {}

// @ts-expect-error — global mock for h3's getRouterParam
globalThis.getRouterParam = (_event: MockEvent, name: string) => _event.__params?.[name]

// @ts-expect-error — global mock for h3's setResponseStatus
globalThis.setResponseStatus = (_event: MockEvent, _status: number) => {}

type MockEvent = {
  __body?: unknown
  __query?: Record<string, string>
  __params?: Record<string, string>
}

export const mockEvent = (opts?: {
  body?: unknown
  query?: Record<string, string>
  params?: Record<string, string>
}): MockEvent => ({
  __body: opts?.body,
  __query: opts?.query,
  __params: opts?.params,
})

mock.module('~/system/logger', () => ({
  createLogger: () => ({
    info: () => {},
    warn: () => {},
    error: () => {},
    debug: () => {},
  }),
}))

import { registerSearchEventHandlers } from '~/domain/search/event-handlers'
import { clearHandlers } from '~/system/event-bus'

afterEach(async () => {
  await clearAllStores()
  clearHandlers()
})

import { beforeEach } from 'bun:test'

beforeEach(() => {
  registerSearchEventHandlers()
})
