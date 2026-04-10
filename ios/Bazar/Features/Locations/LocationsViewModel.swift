import Foundation

@MainActor @Observable
final class LocationsViewModel {
    var places: [Place] = []
    var isLoading = false
    var error: String?

    func load() async {
        isLoading = true
        error = nil
        do {
            places = try await LocationsAPI.allPlaces()
        } catch is CancellationError {
            // Ignored
        } catch {
            self.error = reportError(error)
        }
        isLoading = false
    }

    func createPlace(name: String, icon: String?) async {
        do {
            let place = try await LocationsAPI.createPlace(name: name, icon: icon)
            places.append(place)
        } catch {
            self.error = reportError(error)
        }
    }

    func deletePlace(id: String) async {
        do {
            try await LocationsAPI.deletePlace(id: id)
            places.removeAll { $0.id == id }
        } catch {
            self.error = reportError(error)
        }
    }

    func createRoom(placeId: String, name: String) async {
        do {
            let room = try await LocationsAPI.createRoom(placeId: placeId, name: name)
            guard let index = places.firstIndex(where: { $0.id == placeId }) else { return }
            places[index].rooms.append(room)
        } catch {
            self.error = reportError(error)
        }
    }

    func deleteRoom(id: String) async {
        do {
            try await LocationsAPI.deleteRoom(id: id)
            for placeIndex in places.indices {
                places[placeIndex].rooms.removeAll { $0.id == id }
            }
        } catch {
            self.error = reportError(error)
        }
    }

    func createZone(roomId: String, name: String) async {
        do {
            let zone = try await LocationsAPI.createZone(roomId: roomId, name: name)
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
            try await LocationsAPI.deleteZone(id: id)
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
            let storage = try await LocationsAPI.createStorage(zoneId: zoneId, name: name)
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
            try await LocationsAPI.deleteStorage(id: id)
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
