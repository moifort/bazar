import SwiftUI

enum LocationDestination: Hashable {
    case place(String)
    case room(String)
    case zone(String)
}

struct LocationsView: View {
    @Binding var refreshTrigger: Int

    @State private var viewModel = LocationsViewModel()
    @State private var path: [LocationDestination] = []

    var body: some View {
        NavigationStack(path: $path) {
            LocationsPage(
                places: viewModel.places,
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.error,
                onRefresh: { await viewModel.load() },
                onAddPlace: { name in await viewModel.createPlace(name: name, icon: nil) },
                onDeletePlace: { id in await viewModel.deletePlace(id: id) },
                onEditPlace: { id, name, icon in
                    await viewModel.updatePlace(id: id, name: name, icon: icon)
                },
                onReorderPlaces: { from, to in
                    await viewModel.reorderPlaces(from: from, to: to)
                }
            )
            .task(id: refreshTrigger) {
                await viewModel.load()
            }
            .navigationDestination(for: LocationDestination.self) { destination in
                destinationView(for: destination)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: LocationDestination) -> some View {
        switch destination {
        case .place(let id):
            if let place = viewModel.place(id: id) {
                PlaceDetailPage(
                    place: place,
                    onAddRoom: { name in await viewModel.createRoom(placeId: id, name: name) },
                    onDeleteRoom: { roomId in await viewModel.deleteRoom(id: roomId) },
                    onEditPlace: { name, icon in
                        await viewModel.updatePlace(id: id, name: name, icon: icon)
                    },
                    onEditRoom: { roomId, name, icon in
                        await viewModel.updateRoom(id: roomId, name: name, icon: icon)
                    },
                    onReorderRooms: { from, to in
                        await viewModel.reorderRooms(placeId: id, from: from, to: to)
                    }
                )
            } else {
                missingLocation
            }

        case .room(let id):
            if let room = viewModel.room(id: id) {
                RoomDetailPage(
                    room: room,
                    onAddZone: { name in await viewModel.createZone(roomId: id, name: name) },
                    onDeleteZone: { zoneId in await viewModel.deleteZone(id: zoneId) },
                    onEditRoom: { name, icon in
                        await viewModel.updateRoom(id: id, name: name, icon: icon)
                    },
                    onEditZone: { zoneId, name in
                        await viewModel.updateZone(id: zoneId, name: name)
                    },
                    onReorderZones: { from, to in
                        await viewModel.reorderZones(roomId: id, from: from, to: to)
                    }
                )
            } else {
                missingLocation
            }

        case .zone(let id):
            if let zone = viewModel.zone(id: id) {
                ZoneDetailPage(
                    zone: zone,
                    onAddStorage: { name in await viewModel.createStorage(zoneId: id, name: name) },
                    onDeleteStorage: { storageId in await viewModel.deleteStorage(id: storageId) },
                    onEditZone: { name in
                        await viewModel.updateZone(id: id, name: name)
                    },
                    onEditStorage: { storageId, name in
                        await viewModel.updateStorage(id: storageId, name: name)
                    },
                    onReorderStorages: { from, to in
                        await viewModel.reorderStorages(zoneId: id, from: from, to: to)
                    }
                )
            } else {
                missingLocation
            }
        }
    }

    private var missingLocation: some View {
        ContentUnavailableView(
            "Lieu introuvable",
            systemImage: "mappin.slash",
            description: Text("Ce lieu a été supprimé ou n'existe plus.")
        )
    }
}
