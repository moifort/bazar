import { describe, expect, test } from 'bun:test'
import { make } from 'ts-brand'
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

const place = (name: string): Place => ({
  id: make<PlaceId>()('p1'),
  name: make<PlaceName>()(name),
  icon: null,
  order: 0,
})

const room = (name: string): Room => ({
  id: make<RoomId>()('r1'),
  placeId: make<PlaceId>()('p1'),
  name: make<RoomName>()(name),
  icon: null,
  order: 0,
})

const zone = (name: string): Zone => ({
  id: make<ZoneId>()('z1'),
  roomId: make<RoomId>()('r1'),
  name: make<ZoneName>()(name),
  order: 0,
})

const storage = (name: string): Storage => ({
  id: make<StorageId>()('s1'),
  zoneId: make<ZoneId>()('z1'),
  name: make<StorageName>()(name),
  order: 0,
})

describe('fullPath', () => {
  test('builds the full location path', () => {
    const result = fullPath(
      place('Appartement'),
      room('Cuisine'),
      zone('Placard haut'),
      storage('Etagere 2'),
    )
    expect(result).toBe('Appartement > Cuisine > Placard haut > Etagere 2')
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
