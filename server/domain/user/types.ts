import type { Brand } from 'ts-brand'
import type { UserId } from '~/domain/shared/types'

/** How the user wants to be called, e.g. `"Thibaut"` — a first name, not an identity. */
export type FirstName = Brand<string, 'FirstName'>

/** Who the signed-in account belongs to, as the user introduced themselves.
 *  One document per user, written once when the onboarding is completed.
 *
 *  Its **existence is the flag**: no document means the user has never been
 *  through the onboarding, so there is no `hasOnboarded` boolean to keep in sync
 *  with reality. */
export type User = {
  id: UserId
  firstName: FirstName
  onboardedAt: Date
}
