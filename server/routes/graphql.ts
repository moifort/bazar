import { type ApolloServer, HeaderMap } from '@apollo/server'
import { createLoaders } from '~/domain/shared/graphql/loaders'
import { createLogger } from '~/system/logger'

const log = createLogger('graphql')

type GraphQLBody = { operationName?: string | null }
type GraphQLErrorBody = {
  errors?: Array<{ message?: string; extensions?: { code?: string } }>
}

const extractOperationName = (body: unknown): string => {
  if (body && typeof body === 'object' && 'operationName' in body) {
    const op = (body as GraphQLBody).operationName
    if (typeof op === 'string' && op.length > 0) return op
  }
  return 'anonymous'
}

const logErrorsFromResponseBody = (operation: string, responseBody: string) => {
  try {
    const parsed = JSON.parse(responseBody) as GraphQLErrorBody
    if (!parsed.errors?.length) return
    for (const err of parsed.errors) {
      const code = err.extensions?.code ?? 'UNKNOWN'
      log.warn(`${operation} [${code}] ${err.message ?? '<no message>'}`)
    }
  } catch {
    // Non-JSON response — nothing to extract.
  }
}

export default defineEventHandler(async (event) => {
  const apollo = useApollo()
  const method = event.method
  const userTag = getHeader(event, 'x-user') ?? 'anonymous'
  const headerMap = new HeaderMap()
  Object.entries(getHeaders(event)).forEach(([key, value]) => {
    if (value !== undefined) headerMap.set(key, value)
  })

  if (method === 'GET') {
    const query = getQuery(event)
    const searchParams = new URLSearchParams()
    Object.entries(query).forEach(([key, value]) => {
      if (value !== undefined) searchParams.set(key, String(value))
    })

    const response = await apollo.executeHTTPGraphQLRequest({
      httpGraphQLRequest: {
        method: 'GET',
        headers: headerMap,
        body: undefined,
        search: searchParams.toString(),
      },
      context: async () => ({ event, loaders: createLoaders(), userTag }),
    })

    return sendApolloResponse(event, response)
  }

  const body = await readBody(event)
  const operation = extractOperationName(body)
  log.info(`→ ${operation} from ${userTag}`)

  const response = await apollo.executeHTTPGraphQLRequest({
    httpGraphQLRequest: {
      method: 'POST',
      headers: headerMap,
      body,
      search: '',
    },
    context: async () => ({ event, loaders: createLoaders(), userTag }),
  })

  if (response.body.kind === 'complete') {
    logErrorsFromResponseBody(operation, response.body.string)
  }

  return sendApolloResponse(event, response)
})

function sendApolloResponse(
  event: Parameters<typeof setResponseStatus>[0],
  response: Awaited<ReturnType<ApolloServer['executeHTTPGraphQLRequest']>>,
) {
  setResponseStatus(event, response.status || 200)

  for (const [key, value] of response.headers) {
    setResponseHeader(event, key, value)
  }

  if (response.body.kind === 'complete') {
    return response.body.string
  }

  throw createError({ statusCode: 500, statusMessage: 'Chunked responses not supported' })
}
