import SwiftUI

struct PlaceDetailPage: View {
    let place: Place
    let onAddRoom: (String) async -> Void
    let onDeleteRoom: (String) async -> Void

    @State private var showAddSheet = false

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
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await onDeleteRoom(room.id) }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle(place.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
            onDeleteRoom: { _ in }
        )
    }
}
