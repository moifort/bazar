import SwiftUI

struct RoomDetailPage: View {
    let room: Room
    let onAddZone: (String) async -> Void
    let onDeleteZone: (String) async -> Void
    let onEditRoom: (_ name: String, _ icon: String?) async -> Void
    let onEditZone: (_ id: String, _ name: String) async -> Void

    @State private var showAddSheet = false
    @State private var showEditRoomSheet = false
    @State private var zoneToEdit: Zone?

    var body: some View {
        List {
            if room.zones.isEmpty {
                ContentUnavailableView(
                    "Aucune zone",
                    systemImage: "rectangle.split.3x1",
                    description: Text("Ajoutez une zone pour subdiviser cette pièce")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(room.zones) { zone in
                    NavigationLink(value: LocationDestination.zone(zone.id)) {
                        LocationRow(name: zone.name, icon: "rectangle.split.3x1")
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            zoneToEdit = zone
                        } label: {
                            Label("Modifier", systemImage: "pencil")
                        }
                        .tint(.orange)
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
        }
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    showEditRoomSheet = true
                } label: {
                    Label("Modifier", systemImage: "pencil")
                }
                .accessibilityIdentifier("edit-room-button")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("add-zone-button")
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddLocationSheet(
                title: "Nouvelle zone",
                placeholder: "Nom de la zone",
                onSave: { name in await onAddZone(name) }
            )
        }
        .sheet(isPresented: $showEditRoomSheet) {
            EditLocationSheet(
                title: "Modifier la pièce",
                placeholder: "Nom de la pièce",
                initialName: room.name,
                initialIcon: room.icon,
                showIconField: true,
                onSave: { name, icon in await onEditRoom(name, icon) }
            )
        }
        .sheet(item: $zoneToEdit) { zone in
            EditLocationSheet(
                title: "Modifier la zone",
                placeholder: "Nom de la zone",
                initialName: zone.name,
                onSave: { name, _ in await onEditZone(zone.id, name) }
            )
        }
    }
}

#Preview {
    NavigationStack {
        RoomDetailPage(
            room: Room(
                id: "r1",
                placeId: "p1",
                name: "Garage",
                icon: "car",
                order: 0,
                zones: [
                    Zone(id: "z1", roomId: "r1", name: "Établi", order: 0, storages: []),
                    Zone(id: "z2", roomId: "r1", name: "Étagère droite", order: 1, storages: []),
                ]
            ),
            onAddZone: { _ in },
            onDeleteZone: { _ in },
            onEditRoom: { _, _ in },
            onEditZone: { _, _ in }
        )
    }
}
