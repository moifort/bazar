import { Environment } from '@apple/app-store-server-library'
import { make } from 'ts-brand'
import { z } from 'zod'
import { UserId } from '~/domain/shared/primitives'
import type {
  AdminToken as AdminTokenType,
  AppleAppId as AppleAppIdType,
  GoogleApiKey as GoogleApiKeyType,
} from '~/system/config/types'

export const AdminToken = (value: unknown) => {
  const v = z.string().min(1).parse(value)
  return make<AdminTokenType>()(v)
}

export const GoogleApiKey = (value: unknown) => {
  const v = z.string().min(1).parse(value)
  return make<GoogleApiKeyType>()(v)
}

// The accounts granted Premium outright — the maker's own, a reviewer's — given
// as one comma-separated list of Firebase uids. An override on top of the App
// Store entitlement, never a substitute for it. Blank (the default) means nobody.
export const PremiumUserIds = (value: unknown) => {
  const v = z.string().parse(value ?? '')
  return v
    .split(',')
    .map((id) => id.trim())
    .filter((id) => id.length > 0)
    .map(UserId)
}

// The app's numeric App Store identifier, required to verify a Production
// signature (Apple omits it in the sandbox). Blank until the app has an id.
export const AppleAppId = (value: unknown) => {
  const v = z.coerce.number().int().positive().parse(value)
  return make<AppleAppIdType>()(v)
}

// Pins signature verification to one App Store environment. Blank (production
// default) means both Production and Sandbox are tried, which is what a shipped
// app needs; `Xcode` is for the local StoreKit configuration file.
export const AppleEnvironment = (value: unknown) => z.enum(Environment).parse(value) as Environment
