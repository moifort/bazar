import SwiftUI

struct ZoneDetailPage: View {
    let zone: Zone
    let onAddStorage: (String) async -> Void
    let onDeleteStorage: (String) async -> Void

    @State private var showAddSheet = false

    var body: some View {
        List {
            if zone.storages.isEmpty {
                ContentUnavailableView(
                    "Aucun rangement",
                    systemImage: "archivebox",
                    description: Text("Ajoutez un rangement (tiroir, boîte, étagère)")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(zone.storages) { storage in
                    LocationRow(name: storage.name, icon: "archivebox")
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await onDeleteStorage(storage.id) }
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle(zone.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("add-storage-button")
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddLocationSheet(
                title: "Nouveau rangement",
                placeholder: "Nom du rangement",
                onSave: { name in await onAddStorage(name) }
            )
        }
    }
}

#Preview {
    NavigationStack {
        ZoneDetailPage(
            zone: Zone(
                id: "z1",
                roomId: "r1",
                name: "Établi",
                order: 0,
                storages: [
                    Storage(id: "s1", zoneId: "z1", name: "Tiroir 1", order: 0),
                    Storage(id: "s2", zoneId: "z1", name: "Tiroir 2", order: 1),
                ]
            ),
            onAddStorage: { _ in },
            onDeleteStorage: { _ in }
        )
    }
}
