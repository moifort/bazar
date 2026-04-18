import { ItemQuery } from '~/domain/item/query'
import { builder } from '~/domain/shared/graphql/builder'
import { LocationQuery } from '../../query'
import type { Place, Room, Storage, Zone } from '../../types'

export const PlaceType = builder.objectRef<Place>('Place').implement({
  description: 'A physical location (e.g. Appartement, Cave)',
  fields: (t) => ({
    id: t.expose('id', { type: 'PlaceId', description: 'Place unique identifier' }),
    name: t.expose('name', { type: 'PlaceName', description: 'Place display name' }),
    icon: t.exposeString('icon', { nullable: true, description: 'Optional emoji icon' }),
    order: t.exposeInt('order', { description: 'Sort order' }),
    rooms: t.field({
      type: [RoomType],
      description: 'Rooms in this place',
      resolve: (place) => LocationQuery.roomsByPlace(place.id),
    }),
  }),
})

export const RoomType = builder.objectRef<Room>('Room').implement({
  description: 'A room within a place (e.g. Cuisine, Salon)',
  fields: (t) => ({
    id: t.expose('id', { type: 'RoomId', description: 'Room unique identifier' }),
    placeId: t.expose('placeId', { type: 'PlaceId', description: 'Parent place identifier' }),
    name: t.expose('name', { type: 'RoomName', description: 'Room display name' }),
    icon: t.exposeString('icon', { nullable: true, description: 'Optional emoji icon' }),
    order: t.exposeInt('order', { description: 'Sort order' }),
    zones: t.field({
      type: [ZoneType],
      description: 'Zones in this room',
      resolve: (room) => LocationQuery.zonesByRoom(room.id),
    }),
  }),
})

export const ZoneType = builder.objectRef<Zone>('Zone').implement({
  description: 'A zone within a room (e.g. Placard haut, Etagere metallique)',
  fields: (t) => ({
    id: t.expose('id', { type: 'ZoneId', description: 'Zone unique identifier' }),
    roomId: t.expose('roomId', { type: 'RoomId', description: 'Parent room identifier' }),
    name: t.expose('name', { type: 'ZoneName', description: 'Zone display name' }),
    order: t.exposeInt('order', { description: 'Sort order' }),
    storages: t.field({
      type: [StorageType],
      description: 'Storage spots in this zone',
      resolve: (zone) => LocationQuery.storagesByZone(zone.id),
    }),
    itemCount: t.int({
      description: 'Total number of items stored in any storage of this zone',
      resolve: (zone) => ItemQuery.countByZone(zone.id),
    }),
  }),
})

export const StorageType = builder.objectRef<Storage>('Storage').implement({
  description: 'A specific storage spot (e.g. Etagere 2, Tiroir 3)',
  fields: (t) => ({
    id: t.expose('id', { type: 'StorageId', description: 'Storage unique identifier' }),
    zoneId: t.expose('zoneId', { type: 'ZoneId', description: 'Parent zone identifier' }),
    name: t.expose('name', { type: 'StorageName', description: 'Storage display name' }),
    order: t.exposeInt('order', { description: 'Sort order' }),
  }),
})
