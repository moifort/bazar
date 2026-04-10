import { sortBy } from 'lodash-es'
import type { Place, Room, Storage, Zone } from './types'

export const fullPath = (place: Place, room: Room, zone: Zone, storage: Storage) =>
  `${place.name} > ${room.name} > ${zone.name} > ${storage.name}`

export const sortByOrder = <T extends { order: number }>(items: T[]) =>
  sortBy(items, ({ order }) => order)

export const nextOrder = (items: { order: number }[]) =>
  items.length === 0 ? 0 : Math.max(...items.map(({ order }) => order)) + 1
