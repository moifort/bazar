import { make } from 'ts-brand'
import { z } from 'zod'
import type { ImageId as ImageIdType } from '~/domain/image/types'

export const ImageId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<ImageIdType>()(v)
}
