import Foundation

enum LocationsAPI {
    static func allPlaces() async throws -> [Place] {
        []
    }

    static func createPlace(name: String, icon: String?) async throws -> Place {
        Place(id: UUID().uuidString, name: name, icon: icon, order: 0, rooms: [])
    }

    static func updatePlace(id: String, name: String, icon: String?) async throws -> Place {
        Place(id: id, name: name, icon: icon, order: 0, rooms: [])
    }

    static func deletePlace(id: String) async throws {}

    static func createRoom(placeId: String, name: String) async throws -> Room {
        Room(id: UUID().uuidString, placeId: placeId, name: name, icon: nil, order: 0, zones: [])
    }

    static func deleteRoom(id: String) async throws {}

    static func createZone(roomId: String, name: String) async throws -> Zone {
        Zone(id: UUID().uuidString, roomId: roomId, name: name, order: 0, storages: [])
    }

    static func deleteZone(id: String) async throws {}

    static func createStorage(zoneId: String, name: String) async throws -> Storage {
        Storage(id: UUID().uuidString, zoneId: zoneId, name: name, order: 0)
    }

    static func deleteStorage(id: String) async throws {}
}
