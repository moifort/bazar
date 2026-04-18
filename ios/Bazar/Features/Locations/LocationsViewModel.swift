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

    func updatePlace(id: String, name: String, icon: String?) async {
        do {
            let updated = try await GraphQLLocationsAPI.updatePlace(id: id, name: name, icon: icon)
            guard let index = places.firstIndex(where: { $0.id == id }) else { return }
            places[index].name = updated.name
            places[index].icon = updated.icon
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

    func updateRoom(id: String, name: String, icon: String?) async {
        do {
            let updated = try await GraphQLLocationsAPI.updateRoom(id: id, name: name, icon: icon)
            for placeIndex in places.indices {
                if let roomIndex = places[placeIndex].rooms.firstIndex(where: { $0.id == id }) {
                    places[placeIndex].rooms[roomIndex].name = updated.name
                    places[placeIndex].rooms[roomIndex].icon = updated.icon
                    return
                }
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

    func updateZone(id: String, name: String) async {
        do {
            let updatedName = try await GraphQLLocationsAPI.updateZone(id: id, name: name)
            for placeIndex in places.indices {
                for roomIndex in places[placeIndex].rooms.indices {
                    if let zoneIndex = places[placeIndex].rooms[roomIndex].zones.firstIndex(where: { $0.id == id }) {
                        places[placeIndex].rooms[roomIndex].zones[zoneIndex].name = updatedName
                        return
                    }
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

    func updateStorage(id: String, name: String) async {
        do {
            let updatedName = try await GraphQLLocationsAPI.updateStorage(id: id, name: name)
            for placeIndex in places.indices {
                for roomIndex in places[placeIndex].rooms.indices {
                    for zoneIndex in places[placeIndex].rooms[roomIndex].zones.indices {
                        if let storageIndex = places[placeIndex].rooms[roomIndex].zones[zoneIndex].storages.firstIndex(where: { $0.id == id }) {
                            places[placeIndex].rooms[roomIndex].zones[zoneIndex].storages[storageIndex].name = updatedName
                            return
                        }
                    }
                }
            }
        } catch {
            self.error = reportError(error)
        }
    }

    func reorderPlaces(from source: IndexSet, to destination: Int) async {
        let previous = places
        places.move(fromOffsets: source, toOffset: destination)
        let updates = changedOrders(previous: previous, current: places) { $0.id }
        guard !updates.isEmpty else { return }
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for (id, order) in updates {
                    group.addTask { try await GraphQLLocationsAPI.reorderPlace(id: id, order: order) }
                }
                try await group.waitForAll()
            }
            for index in places.indices {
                places[index].order = index
            }
        } catch {
            self.error = reportError(error)
            await load()
        }
    }

    func reorderRooms(placeId: String, from source: IndexSet, to destination: Int) async {
        guard let placeIndex = places.firstIndex(where: { $0.id == placeId }) else { return }
        let previous = places[placeIndex].rooms
        places[placeIndex].rooms.move(fromOffsets: source, toOffset: destination)
        let updates = changedOrders(previous: previous, current: places[placeIndex].rooms) { $0.id }
        guard !updates.isEmpty else { return }
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for (id, order) in updates {
                    group.addTask { try await GraphQLLocationsAPI.reorderRoom(id: id, order: order) }
                }
                try await group.waitForAll()
            }
            for index in places[placeIndex].rooms.indices {
                places[placeIndex].rooms[index].order = index
            }
        } catch {
            self.error = reportError(error)
            await load()
        }
    }

    func reorderZones(roomId: String, from source: IndexSet, to destination: Int) async {
        guard let location = locateRoom(id: roomId) else { return }
        let placeIndex = location.placeIndex
        let roomIndex = location.roomIndex
        let previous = places[placeIndex].rooms[roomIndex].zones
        places[placeIndex].rooms[roomIndex].zones.move(fromOffsets: source, toOffset: destination)
        let updates = changedOrders(previous: previous, current: places[placeIndex].rooms[roomIndex].zones) { $0.id }
        guard !updates.isEmpty else { return }
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for (id, order) in updates {
                    group.addTask { try await GraphQLLocationsAPI.reorderZone(id: id, order: order) }
                }
                try await group.waitForAll()
            }
            for index in places[placeIndex].rooms[roomIndex].zones.indices {
                places[placeIndex].rooms[roomIndex].zones[index].order = index
            }
        } catch {
            self.error = reportError(error)
            await load()
        }
    }

    func reorderStorages(zoneId: String, from source: IndexSet, to destination: Int) async {
        guard let location = locateZone(id: zoneId) else { return }
        let placeIndex = location.placeIndex
        let roomIndex = location.roomIndex
        let zoneIndex = location.zoneIndex
        let previous = places[placeIndex].rooms[roomIndex].zones[zoneIndex].storages
        places[placeIndex].rooms[roomIndex].zones[zoneIndex].storages.move(fromOffsets: source, toOffset: destination)
        let updates = changedOrders(
            previous: previous,
            current: places[placeIndex].rooms[roomIndex].zones[zoneIndex].storages
        ) { $0.id }
        guard !updates.isEmpty else { return }
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for (id, order) in updates {
                    group.addTask { try await GraphQLLocationsAPI.reorderStorage(id: id, order: order) }
                }
                try await group.waitForAll()
            }
            for index in places[placeIndex].rooms[roomIndex].zones[zoneIndex].storages.indices {
                places[placeIndex].rooms[roomIndex].zones[zoneIndex].storages[index].order = index
            }
        } catch {
            self.error = reportError(error)
            await load()
        }
    }

    private func locateRoom(id: String) -> (placeIndex: Int, roomIndex: Int)? {
        for placeIndex in places.indices {
            if let roomIndex = places[placeIndex].rooms.firstIndex(where: { $0.id == id }) {
                return (placeIndex, roomIndex)
            }
        }
        return nil
    }

    private func locateZone(id: String) -> (placeIndex: Int, roomIndex: Int, zoneIndex: Int)? {
        for placeIndex in places.indices {
            for roomIndex in places[placeIndex].rooms.indices {
                if let zoneIndex = places[placeIndex].rooms[roomIndex].zones.firstIndex(where: { $0.id == id }) {
                    return (placeIndex, roomIndex, zoneIndex)
                }
            }
        }
        return nil
    }

    private func changedOrders<Item>(
        previous: [Item],
        current: [Item],
        id: (Item) -> String
    ) -> [(id: String, order: Int)] {
        let previousOrder = Dictionary(uniqueKeysWithValues: previous.enumerated().map { (id($1), $0) })
        return current.enumerated().compactMap { index, item in
            let itemId = id(item)
            return previousOrder[itemId] == index ? nil : (id: itemId, order: index)
        }
    }
}
