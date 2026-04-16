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
                onDeletePlace: { id in await viewModel.deletePlace(id: id) }
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
                    onDeleteRoom: { roomId in await viewModel.deleteRoom(id: roomId) }
                )
            } else {
                missingLocation
            }

        case .room(let id):
            if let room = viewModel.room(id: id) {
                RoomDetailPage(
                    room: room,
                    onAddZone: { name in await viewModel.createZone(roomId: id, name: name) },
                    onDeleteZone: { zoneId in await viewModel.deleteZone(id: zoneId) }
                )
            } else {
                missingLocation
            }

        case .zone(let id):
            if let zone = viewModel.zone(id: id) {
                ZoneDetailPage(
                    zone: zone,
                    onAddStorage: { name in await viewModel.createStorage(zoneId: id, name: name) },
                    onDeleteStorage: { storageId in await viewModel.deleteStorage(id: storageId) }
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
