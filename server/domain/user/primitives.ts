import { make } from 'ts-brand'
import { z } from 'zod'
import type { FirstName as FirstNameType } from '~/domain/user/types'

export const FirstName = (value: unknown) => {
  const v = z.string().trim().min(1).max(50).parse(value)
  return make<FirstNameType>()(v)
}
