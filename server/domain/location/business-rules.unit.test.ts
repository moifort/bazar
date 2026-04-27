import { describe, expect, test } from 'bun:test'
import { make } from 'ts-brand'
import type { UserId } from '~/domain/shared/types'
import { fullPath, nextOrder, sortByOrder } from './business-rules'
import type {
  Place,
  PlaceId,
  PlaceName,
  Room,
  RoomId,
  RoomName,
  Storage,
  StorageId,
  StorageName,
  Zone,
  ZoneId,
  ZoneName,
} from './types'

const userId = make<UserId>()('user-1')

const place = (name: string): Place => ({
  id: make<PlaceId>()('p1'),
  userId,
  name: make<PlaceName>()(name),
  icon: null,
  order: 0,
})

const room = (name: string): Room => ({
  id: make<RoomId>()('r1'),
  userId,
  placeId: make<PlaceId>()('p1'),
  name: make<RoomName>()(name),
  icon: null,
  order: 0,
})

const zone = (name: string): Zone => ({
  id: make<ZoneId>()('z1'),
  userId,
  roomId: make<RoomId>()('r1'),
  name: make<ZoneName>()(name),
  order: 0,
})

const storage = (name: string): Storage => ({
  id: make<StorageId>()('s1'),
  userId,
  zoneId: make<ZoneId>()('z1'),
  name: make<StorageName>()(name),
  order: 0,
})

describe('fullPath', () => {
  test('builds the full location path including storage', () => {
    const result = fullPath(
      place('Appartement'),
      room('Cuisine'),
      zone('Placard haut'),
      storage('Etagere 2'),
    )
    expect(result).toBe('Appartement > Cuisine > Placard haut > Etagere 2')
  })

  test('builds a zone-only path when storage is null', () => {
    const result = fullPath(place('Appartement'), room('Cuisine'), zone('Placard haut'), null)
    expect(result).toBe('Appartement > Cuisine > Placard haut')
  })
})

describe('sortByOrder', () => {
  test('sorts items by order ascending', () => {
    const items = [{ order: 3 }, { order: 1 }, { order: 2 }]
    expect(sortByOrder(items)).toEqual([{ order: 1 }, { order: 2 }, { order: 3 }])
  })

  test('returns empty array for empty input', () => {
    expect(sortByOrder([])).toEqual([])
  })
})

describe('nextOrder', () => {
  test('returns 0 for empty list', () => {
    expect(nextOrder([])).toBe(0)
  })

  test('returns max + 1', () => {
    expect(nextOrder([{ order: 0 }, { order: 2 }, { order: 1 }])).toBe(3)
  })
})
