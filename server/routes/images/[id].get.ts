import { createHash } from 'node:crypto'
import { ImageId } from '~/domain/image/primitives'
import { ImageQuery } from '~/domain/image/query'

export default defineEventHandler(async (event) => {
  const id = ImageId(getRouterParam(event, 'id'))
  const buffer = await ImageQuery.getById(id)

  if (!buffer) {
    throw createError({ statusCode: 404, statusMessage: 'Image not found' })
  }

  const etag = createHash('sha256').update(buffer).digest('hex').slice(0, 16)

  if (getHeader(event, 'if-none-match') === etag) {
    setResponseStatus(event, 304)
    return null
  }

  setHeader(event, 'Content-Type', 'image/jpeg')
  setHeader(event, 'Cache-Control', 'public, max-age=31536000, immutable')
  setHeader(event, 'ETag', etag)

  return buffer
})
