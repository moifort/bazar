import { make } from 'ts-brand'
import { z } from 'zod'
import type { UserId as UserIdType } from '~/domain/shared/types'

export const UserId = (value: unknown) => {
  const v = z.string().min(1).max(128).parse(value)
  return make<UserIdType>()(v)
}
