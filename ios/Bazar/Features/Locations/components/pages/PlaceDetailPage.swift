import SwiftUI

struct PlaceDetailPage: View {
    let place: Place
    let onAddRoom: (String) async -> Void
    let onDeleteRoom: (String) async -> Void
    let onEditPlace: (_ name: String, _ icon: String?) async -> Void
    let onEditRoom: (_ id: String, _ name: String, _ icon: String?) async -> Void
    let onReorderRooms: (_ from: IndexSet, _ to: Int) async -> Void

    @State private var showAddSheet = false
    @State private var showEditPlaceSheet = false
    @State private var roomToEdit: Room?

    var body: some View {
        List {
            if place.rooms.isEmpty {
                ContentUnavailableView(
                    "Aucune pièce",
                    systemImage: "door.left.hand.open",
                    description: Text("Ajoutez une pièce pour organiser ce lieu")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(place.rooms) { room in
                    NavigationLink(value: LocationDestination.room(room.id)) {
                        LocationRow(name: room.name, icon: room.icon ?? "door.left.hand.open")
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            roomToEdit = room
                        } label: {
                            Label("Modifier", systemImage: "pencil")
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await onDeleteRoom(room.id) }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
                }
                .onMove { from, to in
                    Task { await onReorderRooms(from, to) }
                }
                .onDelete { indexSet in
                    let ids = indexSet.map { place.rooms[$0].id }
                    Task {
                        for id in ids { await onDeleteRoom(id) }
                    }
                }
            }
        }
        .navigationTitle(place.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
                    .accessibilityIdentifier("edit-rooms-button")
            }
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    showEditPlaceSheet = true
                } label: {
                    Label("Modifier", systemImage: "pencil")
                }
                .accessibilityIdentifier("edit-place-button")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("add-room-button")
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddLocationSheet(
                title: "Nouvelle pièce",
                placeholder: "Nom de la pièce",
                onSave: { name in await onAddRoom(name) }
            )
        }
        .sheet(isPresented: $showEditPlaceSheet) {
            EditLocationSheet(
                title: "Modifier le lieu",
                placeholder: "Nom du lieu",
                initialName: place.name,
                initialIcon: place.icon,
                showIconField: true,
                onSave: { name, icon in await onEditPlace(name, icon) }
            )
        }
        .sheet(item: $roomToEdit) { room in
            EditLocationSheet(
                title: "Modifier la pièce",
                placeholder: "Nom de la pièce",
                initialName: room.name,
                initialIcon: room.icon,
                showIconField: true,
                onSave: { name, icon in await onEditRoom(room.id, name, icon) }
            )
        }
    }
}

#Preview {
    NavigationStack {
        PlaceDetailPage(
            place: Place(
                id: "p1",
                name: "Maison",
                icon: "house",
                order: 0,
                rooms: [
                    Room(id: "r1", placeId: "p1", name: "Garage", icon: "car", order: 0, zones: []),
                    Room(id: "r2", placeId: "p1", name: "Salon", icon: "sofa", order: 1, zones: []),
                ]
            ),
            onAddRoom: { _ in },
            onDeleteRoom: { _ in },
            onEditPlace: { _, _ in },
            onEditRoom: { _, _, _ in },
            onReorderRooms: { _, _ in }
        )
    }
}
