import { make } from 'ts-brand'
import { z } from 'zod'
import type { PreviewId as PreviewIdType } from './types'

export const PreviewId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<PreviewIdType>()(v)
}
