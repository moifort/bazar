import Foundation

@MainActor @Observable
final class LocationsViewModel {
    var places: [Place] = []
    var isLoading = false
    var error: String?

    func place(id: String) -> Place? {
        places.first { $0.id == id }
    }

    func room(id: String) -> Room? {
        for place in places {
            if let room = place.rooms.first(where: { $0.id == id }) {
                return room
            }
        }
        return nil
    }

    func zone(id: String) -> Zone? {
        for place in places {
            for room in place.rooms {
                if let zone = room.zones.first(where: { $0.id == id }) {
                    return zone
                }
            }
        }
        return nil
    }

    func load() async {
        isLoading = true
        error = nil
        do {
            places = try await GraphQLLocationsAPI.allPlaces()
        } catch is CancellationError {
            // Ignored
        } catch {
            self.error = reportError(error)
        }
        isLoading = false
    }

    func createPlace(name: String, icon: String?) async {
        do {
            let place = try await GraphQLLocationsAPI.createPlace(name: name, icon: icon)
            places.append(place)
        } catch {
            self.error = reportError(error)
        }
    }

    func deletePlace(id: String) async {
        do {
            try await GraphQLLocationsAPI.deletePlace(id: id)
            places.removeAll { $0.id == id }
        } catch {
            self.error = reportError(error)
        }
    }

    func createRoom(placeId: String, name: String) async {
        do {
            let room = try await GraphQLLocationsAPI.createRoom(placeId: placeId, name: name)
            guard let index = places.firstIndex(where: { $0.id == placeId }) else { return }
            places[index].rooms.append(room)
        } catch {
            self.error = reportError(error)
        }
    }

    func deleteRoom(id: String) async {
        do {
            try await GraphQLLocationsAPI.deleteRoom(id: id)
            for placeIndex in places.indices {
                places[placeIndex].rooms.removeAll { $0.id == id }
            }
        } catch {
            self.error = reportError(error)
        }
    }

    func createZone(roomId: String, name: String) async {
        do {
            let zone = try await GraphQLLocationsAPI.createZone(roomId: roomId, name: name)
            for placeIndex in places.indices {
                for roomIndex in places[placeIndex].rooms.indices {
                    if places[placeIndex].rooms[roomIndex].id == roomId {
                        places[placeIndex].rooms[roomIndex].zones.append(zone)
                        return
                    }
                }
            }
        } catch {
            self.error = reportError(error)
        }
    }

    func deleteZone(id: String) async {
        do {
            try await GraphQLLocationsAPI.deleteZone(id: id)
            for placeIndex in places.indices {
                for roomIndex in places[placeIndex].rooms.indices {
                    places[placeIndex].rooms[roomIndex].zones.removeAll { $0.id == id }
                }
            }
        } catch {
            self.error = reportError(error)
        }
    }

    func createStorage(zoneId: String, name: String) async {
        do {
            let storage = try await GraphQLLocationsAPI.createStorage(zoneId: zoneId, name: name)
            for placeIndex in places.indices {
                for roomIndex in places[placeIndex].rooms.indices {
                    for zoneIndex in places[placeIndex].rooms[roomIndex].zones.indices {
                        if places[placeIndex].rooms[roomIndex].zones[zoneIndex].id == zoneId {
                            places[placeIndex].rooms[roomIndex].zones[zoneIndex].storages.append(storage)
                            return
                        }
                    }
                }
            }
        } catch {
            self.error = reportError(error)
        }
    }

    func deleteStorage(id: String) async {
        do {
            try await GraphQLLocationsAPI.deleteStorage(id: id)
            for placeIndex in places.indices {
                for roomIndex in places[placeIndex].rooms.indices {
                    for zoneIndex in places[placeIndex].rooms[roomIndex].zones.indices {
                        places[placeIndex].rooms[roomIndex].zones[zoneIndex].storages.removeAll { $0.id == id }
                    }
                }
            }
        } catch {
            self.error = reportError(error)
        }
    }
}
