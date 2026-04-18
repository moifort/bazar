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

    @State private var showAddSheet = false
    @State private var placeToEdit: Place?

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
                NavigationLink(value: LocationDestination.place(place.id)) {
                    LocationRow(name: place.name, icon: place.icon ?? "house")
                }
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
                    rooms: []
                ),
                Place(
                    id: "p2",
                    name: "Garage",
                    icon: "car",
                    order: 1,
                    rooms: []
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
