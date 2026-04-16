import SwiftUI

struct LocationsView: View {
    @Binding var refreshTrigger: Int

    @State private var viewModel = LocationsViewModel()

    var body: some View {
        NavigationStack {
            LocationsPage(
                places: viewModel.places,
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.error,
                onRefresh: { await viewModel.load() },
                onAddPlace: { name in await viewModel.createPlace(name: name, icon: nil) },
                onAddRoom: { placeId, name in await viewModel.createRoom(placeId: placeId, name: name) },
                onAddZone: { roomId, name in await viewModel.createZone(roomId: roomId, name: name) },
                onAddStorage: { zoneId, name in await viewModel.createStorage(zoneId: zoneId, name: name) },
                onDeletePlace: { id in await viewModel.deletePlace(id: id) },
                onDeleteRoom: { id in await viewModel.deleteRoom(id: id) },
                onDeleteZone: { id in await viewModel.deleteZone(id: id) },
                onDeleteStorage: { id in await viewModel.deleteStorage(id: id) }
            )
            .task(id: refreshTrigger) {
                await viewModel.load()
            }
        }
    }
}
