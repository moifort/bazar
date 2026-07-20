import DataLoader from 'dataloader'
import { keyBy } from 'lodash-es'
import { fullPath } from '~/domain/location/business-rules'
import type { LocationPath } from '~/domain/location/query'
import { LocationQuery } from '~/domain/location/query'
import type { Place, Room, Storage, StorageId, Zone, ZoneId } from '~/domain/location/types'
import type { UserId } from '~/domain/shared/types'

// The user's whole location tree is small, so each loader reads its collection
// once per request and serves the entire page from it — never one read per item.
const byOwner = <T extends { id: string }>(readAll: () => Promise<T[]>) =>
  new DataLoader<string, T | undefined>(async (ids) => {
    const byId = keyBy(await readAll(), ({ id }) => id)
    return ids.map((id) => byId[id])
  })

type Attachment = { storageId?: StorageId | null; zoneId?: ZoneId | null }

export const createLoaders = (userId: UserId) => {
  const place = byOwner<Place>(() => LocationQuery.allPlaces(userId))
  const room = byOwner<Room>(() => LocationQuery.allRooms(userId))
  const zone = byOwner<Zone>(() => LocationQuery.allZones(userId))
  const storage = byOwner<Storage>(() => LocationQuery.allStorages(userId))

  // Walks up from the item's attachment through the loaders, so a page of items
  // costs four reads in total instead of four per item.
  const locationPath = async (attachment: Attachment): Promise<LocationPath | null> => {
    const attachedStorage = attachment.storageId
      ? await storage.load(attachment.storageId)
      : undefined
    const zoneId = attachedStorage?.zoneId ?? attachment.zoneId
    if (!zoneId) return null

    const attachedZone = await zone.load(zoneId)
    if (!attachedZone) return null
    const attachedRoom = await room.load(attachedZone.roomId)
    if (!attachedRoom) return null
    const attachedPlace = await place.load(attachedRoom.placeId)
    if (!attachedPlace) return null

    return {
      place: attachedPlace,
      room: attachedRoom,
      zone: attachedZone,
      storage: attachedStorage ?? null,
      fullPath: fullPath(attachedPlace, attachedRoom, attachedZone, attachedStorage ?? null),
    }
  }

  return { place, room, zone, storage, locationPath }
}

export type Loaders = ReturnType<typeof createLoaders>
