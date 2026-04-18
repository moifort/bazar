import SwiftUI

struct LocationPicker: View {
    @Binding var selectedStorageId: String?

    @Environment(\.dismiss) private var dismiss
    @State private var places: [Place] = []
    @State private var isLoading = false
    @State private var error: String?
    @State private var addTarget: AddTarget?
    @State private var addName = ""

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && places.isEmpty {
                    ProgressView("Chargement...")
                } else if let error, places.isEmpty {
                    ContentUnavailableView(
                        "Erreur",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if places.isEmpty {
                    ContentUnavailableView(
                        "Aucun lieu",
                        systemImage: "mappin.and.ellipse",
                        description: Text("Créez d'abord un lieu dans l'onglet Lieux")
                    )
                } else {
                    pickerList
                }
            }
            .navigationTitle("Choisir un rangement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Aucun") {
                        selectedStorageId = nil
                        dismiss()
                    }
                }
            }
            .task { await load() }
            .alert(addTarget?.alertTitle ?? "", isPresented: Binding(
                get: { addTarget != nil },
                set: { if !$0 { addTarget = nil; addName = "" } }
            )) {
                TextField("Nom", text: $addName)
                Button("Annuler", role: .cancel) { addTarget = nil; addName = "" }
                Button("Ajouter") {
                    guard let target = addTarget else { return }
                    let name = addName.trimmingCharacters(in: .whitespaces)
                    guard !name.isEmpty else { return }
                    Task {
                        await handleAdd(target: target, name: name)
                        addTarget = nil
                        addName = ""
                    }
                }
            }
        }
    }

    // MARK: - List

    @ViewBuilder
    private var pickerList: some View {
        List {
            ForEach(places) { place in
                Section {
                    ForEach(place.rooms) { room in
                        DisclosureGroup {
                            ForEach(room.zones) { zone in
                                DisclosureGroup {
                                    ForEach(zone.storages) { storage in
                                        Button {
                                            selectedStorageId = storage.id
                                            dismiss()
                                        } label: {
                                            HStack {
                                                Label(storage.name, systemImage: "archivebox")
                                                Spacer()
                                                if selectedStorageId == storage.id {
                                                    Image(systemName: "checkmark")
                                                        .foregroundStyle(.blue)
                                                }
                                            }
                                        }
                                        .tint(.primary)
                                    }

                                    Button {
                                        addTarget = .storage(zoneId: zone.id)
                                    } label: {
                                        Label("Ajouter un rangement", systemImage: "plus.circle")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                } label: {
                                    Label(zone.name, systemImage: "rectangle.split.3x1")
                                }
                            }

                            Button {
                                addTarget = .zone(roomId: room.id)
                            } label: {
                                Label("Ajouter une zone", systemImage: "plus.circle")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } label: {
                            Label(room.name, systemImage: room.icon ?? "door.left.hand.open")
                        }
                    }

                    Button {
                        addTarget = .room(placeId: place.id)
                    } label: {
                        Label("Ajouter une pièce", systemImage: "plus.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    HStack {
                        Image(systemName: place.icon ?? "house")
                        Text(place.name)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func load() async {
        isLoading = true
        error = nil
        do {
            places = try await GraphQLLocationsAPI.allPlaces()
        } catch {
            self.error = reportError(error)
        }
        isLoading = false
    }

    private func handleAdd(target: AddTarget, name: String) async {
        do {
            switch target {
            case .room(let placeId):
                let room = try await GraphQLLocationsAPI.createRoom(placeId: placeId, name: name)
                if let index = places.firstIndex(where: { $0.id == placeId }) {
                    places[index].rooms.append(room)
                }
            case .zone(let roomId):
                let zone = try await GraphQLLocationsAPI.createZone(roomId: roomId, name: name)
                for placeIndex in places.indices {
                    for roomIndex in places[placeIndex].rooms.indices {
                        if places[placeIndex].rooms[roomIndex].id == roomId {
                            places[placeIndex].rooms[roomIndex].zones.append(zone)
                            return
                        }
                    }
                }
            case .storage(let zoneId):
                let storage = try await GraphQLLocationsAPI.createStorage(zoneId: zoneId, name: name)
                for placeIndex in places.indices {
                    for roomIndex in places[placeIndex].rooms.indices {
                        for zoneIndex in places[placeIndex].rooms[roomIndex].zones.indices {
                            if places[placeIndex].rooms[roomIndex].zones[zoneIndex].id == zoneId {
                                places[placeIndex].rooms[roomIndex].zones[zoneIndex].storages.append(storage)
                                return
                            }
                        }
                    }
                }
            }
        } catch {
            self.error = reportError(error)
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

#Preview {
    LocationPicker(selectedStorageId: .constant(nil))
}
