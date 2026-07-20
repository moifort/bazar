import { LocationQuery } from '~/domain/location/query'
import type { StorageId, ZoneId } from '~/domain/location/types'
import { ReminderCommand } from '~/domain/reminder/command'
import type { UserId } from '~/domain/shared/types'
import { type Attachment, ItemCommand, NO_ATTACHMENT } from './command'
import { ItemQuery } from './query'
import type { ItemId } from './types'

/**
 * Orchestrates what an item needs from the other contexts: resolving where it
 * sits (location) and cleaning up what hangs off it (reminders). It calls the
 * public Command/Query namespaces only — never a repository.
 */

type AttachmentInput = {
  storageId?: string | null
  zoneId?: string | null
}

const attachmentOf = async (
  userId: UserId,
  input: AttachmentInput,
): Promise<Attachment | 'invalid-location' | 'location-not-found'> => {
  if (input.storageId && input.zoneId) return 'invalid-location'

  if (input.storageId) {
    const path = await LocationQuery.resolveLocationPath(userId, input.storageId as StorageId)
    if (!path) return 'location-not-found'
    return { storageId: input.storageId as StorageId, zoneId: null, placeId: path.place.id }
  }

  if (input.zoneId) {
    const path = await LocationQuery.resolveZoneLocationPath(userId, input.zoneId as ZoneId)
    if (!path) return 'location-not-found'
    return { storageId: null, zoneId: input.zoneId as ZoneId, placeId: path.place.id }
  }

  return NO_ATTACHMENT
}

type AddInput = Omit<Parameters<typeof ItemCommand.add>[0], 'userId' | 'attachment'> &
  AttachmentInput

const add = async (userId: UserId, input: AddInput) => {
  const attachment = await attachmentOf(userId, input)
  if (typeof attachment === 'string') return attachment
  return ItemCommand.add({ ...input, userId, attachment })
}

const move = async (userId: UserId, id: ItemId, target: AttachmentInput) => {
  const attachment = await attachmentOf(userId, target)
  if (typeof attachment === 'string') return attachment
  return ItemCommand.move(userId, id, attachment)
}

const confirmScanned = async (userId: UserId, inputs: AddInput[]) =>
  Promise.all(inputs.map((input) => add(userId, input)))

// A reminder without its item is meaningless, so deleting the item drops them.
const remove = async (userId: UserId, id: ItemId) => {
  const outcome = await ItemCommand.remove(userId, id)
  if (outcome === 'not-found') return outcome
  await ReminderCommand.removeByItem(userId, id)
  return outcome
}

// Reminders hang off an item, so the item context is the one that vouches for
// its existence — `reminder` never reaches back into `item`.
const addReminder = async (userId: UserId, input: Parameters<typeof ReminderCommand.add>[1]) => {
  const item = await ItemQuery.itemById(userId, input.itemId)
  if (!item) return 'item-not-found' as const
  return ReminderCommand.add(userId, input)
}

export const ItemUseCase = { add, move, confirmScanned, remove, addReminder }
