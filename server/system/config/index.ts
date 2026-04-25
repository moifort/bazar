import type { Brand } from 'ts-brand'

type AdminToken = Brand<string, 'AdminToken'>
type GoogleApiKey = Brand<string, 'GoogleApiKey'>

export const config = () => {
  const runtimeConfig = useRuntimeConfig()
  return {
    adminToken: runtimeConfig.adminToken as AdminToken,
    googleApiKey: runtimeConfig.googleApiKey as GoogleApiKey,
  }
}
