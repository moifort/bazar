import SwiftUI

struct RoomDetailPage: View {
    let room: Room
    let onAddZone: (String) async -> Void
    let onDeleteZone: (String) async -> Void

    @State private var showAddSheet = false

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
            onDeleteZone: { _ in }
        )
    }
}
