import Apollo

enum GraphQLLocationsAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func allPlaces() async throws -> [Place] {
        let query = BazarGraphQL.AllPlacesQuery()
        let data = try await GraphQLHelpers.fetch(client, query: query)
        return data.places.map { place in
            Place(
                id: place.id,
                name: place.name,
                icon: place.icon,
                order: place.order,
                rooms: place.rooms.map { room in
                    Room(
                        id: room.id,
                        placeId: room.placeId,
                        name: room.name,
                        icon: room.icon,
                        order: room.order,
                        zones: room.zones.map { zone in
                            Zone(
                                id: zone.id,
                                roomId: zone.roomId,
                                name: zone.name,
                                order: zone.order,
                                itemCount: zone.itemCount,
                                storages: zone.storages.map { storage in
                                    Storage(
                                        id: storage.id,
                                        zoneId: storage.zoneId,
                                        name: storage.name,
                                        order: storage.order
                                    )
                                }
                            )
                        }
                    )
                }
            )
        }
    }

    static func createPlace(name: String, icon: String?) async throws -> Place {
        let input = BazarGraphQL.CreatePlaceInput(
            icon: GraphQLHelpers.graphQLNullable(icon),
            name: name
        )
        let mutation = BazarGraphQL.CreatePlaceMutation(input: input)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        let p = data.createPlace
        return Place(id: p.id, name: p.name, icon: p.icon, order: p.order, rooms: [])
    }

    static func updatePlace(id: String, name: String, icon: String?) async throws -> (name: String, icon: String?) {
        let input = BazarGraphQL.UpdatePlaceInput(
            icon: icon.map { .some($0) } ?? .null,
            name: .some(name)
        )
        let mutation = BazarGraphQL.UpdatePlaceMutation(id: id, input: input)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        let p = data.updatePlace
        return (name: p.name, icon: p.icon)
    }

    static func deletePlace(id: String) async throws {
        let mutation = BazarGraphQL.DeletePlaceMutation(id: id)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func reorderPlace(id: String, order: Int) async throws {
        let input = BazarGraphQL.UpdatePlaceInput(order: .some(order))
        let mutation = BazarGraphQL.UpdatePlaceMutation(id: id, input: input)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func createRoom(placeId: String, name: String) async throws -> Room {
        let input = BazarGraphQL.CreateRoomInput(name: name, placeId: placeId)
        let mutation = BazarGraphQL.CreateRoomMutation(input: input)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        let r = data.createRoom
        return Room(id: r.id, placeId: r.placeId, name: r.name, icon: r.icon, order: r.order, zones: [])
    }

    static func updateRoom(id: String, name: String, icon: String?) async throws -> (name: String, icon: String?) {
        let input = BazarGraphQL.UpdateRoomInput(
            icon: icon.map { .some($0) } ?? .null,
            name: .some(name)
        )
        let mutation = BazarGraphQL.UpdateRoomMutation(id: id, input: input)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        let r = data.updateRoom
        return (name: r.name, icon: r.icon)
    }

    static func deleteRoom(id: String) async throws {
        let mutation = BazarGraphQL.DeleteRoomMutation(id: id)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func reorderRoom(id: String, order: Int) async throws {
        let input = BazarGraphQL.UpdateRoomInput(order: .some(order))
        let mutation = BazarGraphQL.UpdateRoomMutation(id: id, input: input)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func createZone(roomId: String, name: String) async throws -> Zone {
        let input = BazarGraphQL.CreateZoneInput(name: name, roomId: roomId)
        let mutation = BazarGraphQL.CreateZoneMutation(input: input)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        let z = data.createZone
        return Zone(id: z.id, roomId: z.roomId, name: z.name, order: z.order, itemCount: 0, storages: [])
    }

    static func updateZone(id: String, name: String) async throws -> String {
        let input = BazarGraphQL.UpdateZoneInput(name: .some(name))
        let mutation = BazarGraphQL.UpdateZoneMutation(id: id, input: input)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        return data.updateZone.name
    }

    static func deleteZone(id: String) async throws {
        let mutation = BazarGraphQL.DeleteZoneMutation(id: id)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func reorderZone(id: String, order: Int) async throws {
        let input = BazarGraphQL.UpdateZoneInput(order: .some(order))
        let mutation = BazarGraphQL.UpdateZoneMutation(id: id, input: input)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func createStorage(zoneId: String, name: String) async throws -> Storage {
        let input = BazarGraphQL.CreateStorageInput(name: name, zoneId: zoneId)
        let mutation = BazarGraphQL.CreateStorageMutation(input: input)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        let s = data.createStorage
        return Storage(id: s.id, zoneId: s.zoneId, name: s.name, order: s.order)
    }

    static func updateStorage(id: String, name: String) async throws -> String {
        let input = BazarGraphQL.UpdateStorageInput(name: .some(name))
        let mutation = BazarGraphQL.UpdateStorageMutation(id: id, input: input)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        return data.updateStorage.name
    }

    static func deleteStorage(id: String) async throws {
        let mutation = BazarGraphQL.DeleteStorageMutation(id: id)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func reorderStorage(id: String, order: Int) async throws {
        let input = BazarGraphQL.UpdateStorageInput(order: .some(order))
        let mutation = BazarGraphQL.UpdateStorageMutation(id: id, input: input)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }
}
