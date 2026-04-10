import SwiftUI

struct LocationsPage: View {
    @Binding var refreshTrigger: Int

    @State private var viewModel = LocationsViewModel()
    @State private var newPlaceName = ""
    @State private var showAddPlace = false
    @State private var addTarget: AddTarget?
    @State private var addName = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.places.isEmpty {
                    ProgressView("Chargement...")
                } else if let error = viewModel.error, viewModel.places.isEmpty {
                    ContentUnavailableView(
                        "Erreur",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if viewModel.places.isEmpty {
                    ContentUnavailableView(
                        "Aucun lieu",
                        systemImage: "mappin.and.ellipse",
                        description: Text("Ajoutez un lieu pour organiser vos objets")
                    )
                } else {
                    locationsList
                }
            }
            .navigationTitle("Lieux")
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await viewModel.load() }
            .task(id: refreshTrigger) {
                await viewModel.load()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddPlace = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("add-place-button")
                }
            }
            .alert("Nouveau lieu", isPresented: $showAddPlace) {
                TextField("Nom du lieu", text: $newPlaceName)
                Button("Annuler", role: .cancel) { newPlaceName = "" }
                Button("Ajouter") {
                    let name = newPlaceName.trimmingCharacters(in: .whitespaces)
                    guard !name.isEmpty else { return }
                    Task { await viewModel.createPlace(name: name, icon: nil) }
                    newPlaceName = ""
                }
            }
            .alert(addTarget?.alertTitle ?? "", isPresented: Binding(
                get: { addTarget != nil },
                set: { if !$0 { addTarget = nil; addName = "" } }
            )) {
                TextField("Nom", text: $addName)
                Button("Annuler", role: .cancel) { addTarget = nil; addName = "" }
                Button("Ajouter") {
                    let name = addName.trimmingCharacters(in: .whitespaces)
                    guard !name.isEmpty else { return }
                    Task { await handleAdd(name: name) }
                    addTarget = nil
                    addName = ""
                }
            }
        }
    }

    // MARK: - List

    @ViewBuilder
    private var locationsList: some View {
        List {
            ForEach(viewModel.places) { place in
                Section {
                    roomsContent(for: place)

                    Button {
                        addTarget = .room(placeId: place.id)
                    } label: {
                        Label("Ajouter une pièce", systemImage: "plus.circle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    HStack {
                        Image(systemName: place.icon ?? "house")
                        Text(place.name)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { await viewModel.deletePlace(id: place.id) }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func roomsContent(for place: Place) -> some View {
        ForEach(place.rooms) { room in
            DisclosureGroup {
                zonesContent(for: room)

                Button {
                    addTarget = .zone(roomId: room.id)
                } label: {
                    Label("Ajouter une zone", systemImage: "plus.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } label: {
                LocationRow(name: room.name, icon: room.icon ?? "door.left.hand.open", depth: 1)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    Task { await viewModel.deleteRoom(id: room.id) }
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }
            }
        }
    }

    @ViewBuilder
    private func zonesContent(for room: Room) -> some View {
        ForEach(room.zones) { zone in
            DisclosureGroup {
                storagesContent(for: zone)

                Button {
                    addTarget = .storage(zoneId: zone.id)
                } label: {
                    Label("Ajouter un rangement", systemImage: "plus.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } label: {
                LocationRow(name: zone.name, icon: "rectangle.split.3x1", depth: 2)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    Task { await viewModel.deleteZone(id: zone.id) }
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }
            }
        }
    }

    @ViewBuilder
    private func storagesContent(for zone: Zone) -> some View {
        ForEach(zone.storages) { storage in
            LocationRow(name: storage.name, icon: "archivebox", depth: 3)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { await viewModel.deleteStorage(id: storage.id) }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
        }
    }

    // MARK: - Add Helpers

    private func handleAdd(name: String) async {
        guard let target = addTarget else { return }
        switch target {
        case .room(let placeId):
            await viewModel.createRoom(placeId: placeId, name: name)
        case .zone(let roomId):
            await viewModel.createZone(roomId: roomId, name: name)
        case .storage(let zoneId):
            await viewModel.createStorage(zoneId: zoneId, name: name)
        }
    }
}

// MARK: - Add Target

private enum AddTarget {
    case room(placeId: String)
    case zone(roomId: String)
    case storage(zoneId: String)

    var alertTitle: String {
        switch self {
        case .room: "Nouvelle pièce"
        case .zone: "Nouvelle zone"
        case .storage: "Nouveau rangement"
        }
    }
}

#Preview {
    LocationsPage(refreshTrigger: .constant(0))
}
