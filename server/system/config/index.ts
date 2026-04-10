import type { Brand } from 'ts-brand'

type ApiToken = Brand<string, 'ApiToken'>
type GoogleApiKey = Brand<string, 'GoogleApiKey'>

export const config = () => {
  const runtimeConfig = useRuntimeConfig()
  return {
    apiToken: runtimeConfig.apiToken as ApiToken,
    googleApiKey: runtimeConfig.googleApiKey as GoogleApiKey,
  }
}
