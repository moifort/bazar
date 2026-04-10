import { type ApolloServer, HeaderMap } from '@apollo/server'
import { createLoaders } from '~/domain/shared/graphql/loaders'

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

  const response = await apollo.executeHTTPGraphQLRequest({
    httpGraphQLRequest: {
      method: 'POST',
      headers: headerMap,
      body,
      search: '',
    },
    context: async () => ({ event, loaders: createLoaders(), userTag }),
  })

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
