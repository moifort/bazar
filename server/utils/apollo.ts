import type { ApolloServer } from '@apollo/server'
import type { GraphQLContext } from '~/domain/shared/graphql/builder'

let instance: ApolloServer<GraphQLContext> | null = null

export function setApollo(apollo: ApolloServer<GraphQLContext>) {
  instance = apollo
}

export function useApollo() {
  if (!instance) throw new Error('Apollo Server not initialized — plugin not loaded yet')
  return instance
}
