import * as repository from './infrastructure/repository'
import type { ImageId } from './types'

const getById = async (id: ImageId) => {
  const image = await repository.findBy(id)
  if (!image) return null
  return Buffer.from(image.data, 'base64')
}

export const ImageQuery = { getById }
