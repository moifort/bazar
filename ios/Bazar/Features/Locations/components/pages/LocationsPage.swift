import SwiftUI

struct LocationsPage: View {
    let places: [Place]
    let isLoading: Bool
    let errorMessage: String?
    let onRefresh: () async -> Void
    let onAddPlace: (String) async -> Void
    let onAddRoom: (String, String) async -> Void
    let onAddZone: (String, String) async -> Void
    let onAddStorage: (String, String) async -> Void
    let onDeletePlace: (String) async -> Void
    let onDeleteRoom: (String) async -> Void
    let onDeleteZone: (String) async -> Void
    let onDeleteStorage: (String) async -> Void

    @State private var newPlaceName = ""
    @State private var showAddPlace = false
    @State private var addTarget: AddTarget?
    @State private var addName = ""

    var body: some View {
        Group {
            if isLoading && places.isEmpty {
                ProgressView("Chargement...")
            } else if let errorMessage, places.isEmpty {
                ContentUnavailableView(
                    "Erreur",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if places.isEmpty {
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
        .refreshable { await onRefresh() }
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
                newPlaceName = ""
                guard !name.isEmpty else { return }
                Task { await onAddPlace(name) }
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
                let target = addTarget
                addTarget = nil
                addName = ""
                guard !name.isEmpty, let target else { return }
                Task { await handleAdd(target: target, name: name) }
            }
        }
    }

    @ViewBuilder
    private var locationsList: some View {
        List {
            ForEach(places) { place in
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
                        Task { await onDeletePlace(place.id) }
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
                    Task { await onDeleteRoom(room.id) }
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
                    Task { await onDeleteZone(zone.id) }
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
                        Task { await onDeleteStorage(storage.id) }
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                }
        }
    }

    private func handleAdd(target: AddTarget, name: String) async {
        switch target {
        case .room(let placeId): await onAddRoom(placeId, name)
        case .zone(let roomId): await onAddZone(roomId, name)
        case .storage(let zoneId): await onAddStorage(zoneId, name)
        }
    }
}

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

#Preview("Loaded") {
    NavigationStack {
        LocationsPage(
            places: [
                Place(
                    id: "p1",
                    name: "Maison",
                    icon: "house",
                    order: 0,
                    rooms: [
                        Room(
                            id: "r1",
                            placeId: "p1",
                            name: "Garage",
                            icon: "car",
                            order: 0,
                            zones: [
                                Zone(id: "z1", roomId: "r1", name: "Établi", order: 0, storages: [
                                    Storage(id: "s1", zoneId: "z1", name: "Tiroir 1", order: 0),
                                ]),
                            ]
                        ),
                    ]
                ),
            ],
            isLoading: false,
            errorMessage: nil,
            onRefresh: {},
            onAddPlace: { _ in },
            onAddRoom: { _, _ in },
            onAddZone: { _, _ in },
            onAddStorage: { _, _ in },
            onDeletePlace: { _ in },
            onDeleteRoom: { _ in },
            onDeleteZone: { _ in },
            onDeleteStorage: { _ in }
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        LocationsPage(
            places: [],
            isLoading: false,
            errorMessage: nil,
            onRefresh: {},
            onAddPlace: { _ in },
            onAddRoom: { _, _ in },
            onAddZone: { _, _ in },
            onAddStorage: { _, _ in },
            onDeletePlace: { _ in },
            onDeleteRoom: { _ in },
            onDeleteZone: { _ in },
            onDeleteStorage: { _ in }
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        LocationsPage(
            places: [],
            isLoading: true,
            errorMessage: nil,
            onRefresh: {},
            onAddPlace: { _ in },
            onAddRoom: { _, _ in },
            onAddZone: { _, _ in },
            onAddStorage: { _, _ in },
            onDeletePlace: { _ in },
            onDeleteRoom: { _ in },
            onDeleteZone: { _ in },
            onDeleteStorage: { _ in }
        )
    }
}

#Preview("Error") {
    NavigationStack {
        LocationsPage(
            places: [],
            isLoading: false,
            errorMessage: "Connexion impossible",
            onRefresh: {},
            onAddPlace: { _ in },
            onAddRoom: { _, _ in },
            onAddZone: { _, _ in },
            onAddStorage: { _, _ in },
            onDeletePlace: { _ in },
            onDeleteRoom: { _ in },
            onDeleteZone: { _ in },
            onDeleteStorage: { _ in }
        )
    }
}
