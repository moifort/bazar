import SwiftUI

struct LocationsPage: View {
    let places: [Place]
    let isLoading: Bool
    let errorMessage: String?
    let onRefresh: () async -> Void
    let onAddPlace: (String) async -> Void
    let onDeletePlace: (String) async -> Void
    let onEditPlace: (_ id: String, _ name: String, _ icon: String?) async -> Void
    let onReorderPlaces: (_ from: IndexSet, _ to: Int) async -> Void

    /// Initial cap on zones shown per room before the user expands the list.
    private static let zonesInitialLimit = 3

    @State private var showAddSheet = false
    @State private var placeToEdit: Place?
    // Place expansion: presence in the set means collapsed (empty = all expanded).
    @State private var collapsedPlaces: Set<String> = []
    // Room expansion: presence in the set means expanded (empty = all collapsed).
    @State private var expandedRooms: Set<String> = []
    // Rooms for which the user tapped "Voir toutes les zones".
    @State private var roomsWithAllZones: Set<String> = []

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
                placesList
            }
        }
        .navigationTitle("Lieux")
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await onRefresh() }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
                    .accessibilityIdentifier("edit-places-button")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("add-place-button")
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddLocationSheet(
                title: "Nouveau lieu",
                placeholder: "Nom du lieu",
                onSave: { name in await onAddPlace(name) }
            )
        }
        .sheet(item: $placeToEdit) { place in
            EditLocationSheet(
                title: "Modifier le lieu",
                placeholder: "Nom du lieu",
                initialName: place.name,
                initialIcon: place.icon,
                showIconField: true,
                onSave: { name, icon in await onEditPlace(place.id, name, icon) }
            )
        }
    }

    @ViewBuilder
    private var placesList: some View {
        List {
            ForEach(places) { place in
                placeDisclosure(for: place)
                    .swipeActions(edge: .leading) {
                        Button {
                            placeToEdit = place
                        } label: {
                            Label("Modifier", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await onDeletePlace(place.id) }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }
            .onMove { from, to in
                Task { await onReorderPlaces(from, to) }
            }
            .onDelete { indexSet in
                let ids = indexSet.map { places[$0].id }
                Task {
                    for id in ids { await onDeletePlace(id) }
                }
            }
        }
    }

    @ViewBuilder
    private func placeDisclosure(for place: Place) -> some View {
        DisclosureGroup(isExpanded: placeExpansionBinding(for: place.id)) {
            ForEach(place.rooms) { room in
                roomDisclosure(for: room)
            }
        } label: {
            NavigationLink(value: LocationDestination.place(place.id)) {
                LocationRow(name: place.name, icon: place.icon ?? "house")
            }
        }
    }

    @ViewBuilder
    private func roomDisclosure(for room: Room) -> some View {
        let allZones = sortedZones(in: room)
        let showingAll = roomsWithAllZones.contains(room.id)
        let displayedZones = showingAll ? allZones : Array(allZones.prefix(Self.zonesInitialLimit))
        let hiddenCount = allZones.count - displayedZones.count

        DisclosureGroup(isExpanded: roomExpansionBinding(for: room.id)) {
            ForEach(displayedZones) { zone in
                NavigationLink(value: LocationDestination.zone(zone.id)) {
                    LocationRow(name: zone.name, icon: "rectangle.split.3x1")
                }
            }

            if hiddenCount > 0 {
                Button {
                    roomsWithAllZones.insert(room.id)
                } label: {
                    Label(
                        "Voir toutes les zones (\(allZones.count))",
                        systemImage: "chevron.down"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("show-all-zones-\(room.id)")
            }
        } label: {
            NavigationLink(value: LocationDestination.room(room.id)) {
                LocationRow(name: room.name, icon: room.icon ?? "door.left.hand.open")
            }
        }
    }

    /// Sorts zones so the busiest ones surface first; ties fall back to alphabetical order
    /// to keep the ordering stable when counts match (e.g. all zeros for a brand new room).
    private func sortedZones(in room: Room) -> [Zone] {
        room.zones.sorted { lhs, rhs in
            if lhs.itemCount != rhs.itemCount {
                return lhs.itemCount > rhs.itemCount
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private func placeExpansionBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { !collapsedPlaces.contains(id) },
            set: { isExpanded in
                if isExpanded {
                    collapsedPlaces.remove(id)
                } else {
                    collapsedPlaces.insert(id)
                }
            }
        )
    }

    private func roomExpansionBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: { expandedRooms.contains(id) },
            set: { isExpanded in
                if isExpanded {
                    expandedRooms.insert(id)
                } else {
                    expandedRooms.remove(id)
                }
            }
        )
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
                            name: "Salon",
                            icon: "sofa",
                            order: 0,
                            zones: [
                                Zone(id: "z1", roomId: "r1", name: "Meuble TV", order: 0, itemCount: 4, storages: []),
                                Zone(id: "z2", roomId: "r1", name: "Bibliothèque", order: 1, itemCount: 12, storages: []),
                            ]
                        ),
                        Room(
                            id: "r2",
                            placeId: "p1",
                            name: "Cuisine",
                            icon: "fork.knife",
                            order: 1,
                            zones: []
                        ),
                    ]
                ),
                Place(
                    id: "p2",
                    name: "Garage",
                    icon: "car",
                    order: 1,
                    rooms: [
                        Room(
                            id: "r3",
                            placeId: "p2",
                            name: "Atelier",
                            icon: "hammer",
                            order: 0,
                            zones: [
                                Zone(id: "z3", roomId: "r3", name: "Établi", order: 0, itemCount: 8, storages: []),
                                Zone(id: "z4", roomId: "r3", name: "Étagère droite", order: 1, itemCount: 15, storages: []),
                                Zone(id: "z5", roomId: "r3", name: "Étagère gauche", order: 2, itemCount: 3, storages: []),
                                Zone(id: "z6", roomId: "r3", name: "Mur arrière", order: 3, itemCount: 0, storages: []),
                                Zone(id: "z7", roomId: "r3", name: "Tiroirs", order: 4, itemCount: 6, storages: []),
                            ]
                        ),
                    ]
                ),
            ],
            isLoading: false,
            errorMessage: nil,
            onRefresh: {},
            onAddPlace: { _ in },
            onDeletePlace: { _ in },
            onEditPlace: { _, _, _ in },
            onReorderPlaces: { _, _ in }
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
            onDeletePlace: { _ in },
            onEditPlace: { _, _, _ in },
            onReorderPlaces: { _, _ in }
        )
    }
}
