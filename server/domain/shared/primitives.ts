import { make } from 'ts-brand'
import { z } from 'zod'
import type { UserTag as UserTagType } from '~/domain/shared/types'

export const UserTag = (value: unknown) => {
  const v = z.string().min(1).max(50).parse(value)
  return make<UserTagType>()(v)
}
