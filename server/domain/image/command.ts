import { randomUUID } from 'node:crypto'
import * as repository from './infrastructure/repository'
import { ImageId } from './primitives'
import type { Image } from './types'

const save = async (data: string, mimeType: string) => {
  const image: Image = {
    id: ImageId(randomUUID()),
    data,
    mimeType,
    createdAt: new Date(),
  }
  await repository.save(image)
  return image
}

const remove = async (id: Image['id']) => {
  await repository.remove(id)
}

export const ImageCommand = { save, remove }
