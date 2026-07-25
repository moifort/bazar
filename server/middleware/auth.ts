import { getAuth } from 'firebase-admin/auth'
import { UserId } from '~/domain/shared/primitives'
// Side-effect import: ensures firebase-admin is initialized before verifyIdToken.
import '~/system/firebase'
import { config } from '~/system/config'

export default defineEventHandler(async (event) => {
  const path = event.path ?? ''

  if (path === '/health') return

  // The App Store webhook has no user to authenticate as: its proof of origin is
  // Apple's signature on the payload, checked by the handler itself.
  if (path.startsWith('/apple/')) return

  if (path.startsWith('/admin/')) {
    const auth = getHeader(event, 'authorization')
    const adminToken = config().adminToken
    if (!adminToken || auth !== `Bearer ${adminToken}`)
      throw createError({ statusCode: 401, statusMessage: 'Unauthorized' })
    return
  }

  const auth = getHeader(event, 'authorization')
  const token = auth?.startsWith('Bearer ') ? auth.slice(7) : null
  if (!token) throw createError({ statusCode: 401, statusMessage: 'Missing bearer token' })

  try {
    const decoded = await getAuth().verifyIdToken(token)
    event.context.userId = UserId(decoded.uid)
  } catch {
    throw createError({ statusCode: 401, statusMessage: 'Invalid token' })
  }
})

declare module 'h3' {
  interface H3EventContext {
    userId?: ReturnType<typeof UserId>
  }
}
