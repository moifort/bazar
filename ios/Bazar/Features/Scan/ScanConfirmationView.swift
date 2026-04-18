import SwiftUI

/// Connected container for the scan confirmation step.
/// Owns the editable preview list, storage selection, LocationPicker sheet,
/// async confirm action and breadcrumb resolution. Renders through the pure
/// `ScanConfirmationPage` view.
struct ScanConfirmationView: View {
    let previews: [ItemPreview]
    let onScanAnother: () -> Void
    let onConfirm: ([ItemPreview], String?) async -> Void

    @State private var editablePreviews: [EditablePreview]
    @State private var selectedStorageId: String?
    @State private var showLocationPicker = false
    @State private var isConfirming = false
    @State private var places: [Place] = []
    @FocusState private var focused: ItemPreviewField?

    init(
        previews: [ItemPreview],
        onScanAnother: @escaping () -> Void,
        onConfirm: @escaping ([ItemPreview], String?) async -> Void
    ) {
        self.previews = previews
        self.onScanAnother = onScanAnother
        self.onConfirm = onConfirm
        _editablePreviews = State(initialValue: previews.map { EditablePreview(from: $0) })
        _selectedStorageId = State(
            initialValue: UserDefaults.standard.string(forKey: "lastStorageId")
        )
    }

    var body: some View {
        ScanConfirmationPage(
            previews: $editablePreviews,
            storageName: resolvedStorage?.name,
            breadcrumb: resolvedStorage?.breadcrumb,
            isConfirming: isConfirming,
            focus: $focused,
            onOpenLocationPicker: { showLocationPicker = true },
            onAdd: addItem,
            onDuplicate: duplicate(id:),
            onDelete: delete(id:),
            onScanAnother: onScanAnother,
            onConfirm: { Task { await confirm() } }
        )
        .sheet(isPresented: $showLocationPicker) {
            LocationPicker(selectedStorageId: $selectedStorageId)
        }
        .task { await loadPlaces() }
        .onAppear(perform: autoFocusIfSingle)
    }

    // MARK: - Actions

    private func addItem() {
        let new = EditablePreview(
            id: UUID().uuidString,
            name: "",
            category: nil,
            description: "",
            quantity: 1
        )
        withAnimation(.snappy) {
            editablePreviews.append(new)
        }
        focused = .name(new.id)
    }

    private func duplicate(id: String) {
        guard let index = editablePreviews.firstIndex(where: { $0.id == id }) else { return }
        var copy = editablePreviews[index]
        copy = EditablePreview(
            id: UUID().uuidString,
            name: copy.name,
            category: copy.category,
            description: copy.description,
            quantity: copy.quantity
        )
        withAnimation(.snappy) {
            editablePreviews.insert(copy, at: index + 1)
        }
    }

    private func delete(id: String) {
        if focused == .name(id) { focused = nil }
        withAnimation(.snappy) {
            editablePreviews.removeAll { $0.id == id }
        }
    }

    private func confirm() async {
        isConfirming = true
        focused = nil
        let items = editablePreviews.map { $0.toPreview() }
        if let storageId = selectedStorageId {
            UserDefaults.standard.set(storageId, forKey: "lastStorageId")
        }
        await onConfirm(items, selectedStorageId)
        isConfirming = false
    }

    private func autoFocusIfSingle() {
        guard editablePreviews.count == 1, let first = editablePreviews.first else { return }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 250_000_000)
            focused = .name(first.id)
        }
    }

    // MARK: - Breadcrumb

    private func loadPlaces() async {
        do {
            places = try await GraphQLLocationsAPI.allPlaces()
        } catch {
            // Silent failure: the header card gracefully falls back to the
            // default "Choisir un emplacement" prompt when no storage resolves.
        }
    }

    private var resolvedStorage: (name: String, breadcrumb: String)? {
        guard let storageId = selectedStorageId else { return nil }
        for place in places {
            for room in place.rooms {
                for zone in room.zones {
                    if let storage = zone.storages.first(where: { $0.id == storageId }) {
                        let breadcrumb = "\(place.name) · \(room.name) · \(zone.name)"
                        return (storage.name, breadcrumb)
                    }
                }
            }
        }
        return nil
    }
}

#Preview {
    NavigationStack {
        ScanConfirmationView(
            previews: [
                ItemPreview(
                    previewId: "1",
                    name: "Perceuse Bosch",
                    category: .tools,
                    description: "Perceuse visseuse 18V",
                    quantity: 1
                ),
                ItemPreview(
                    previewId: "2",
                    name: "Tournevis",
                    category: .tools,
                    description: "",
                    quantity: 3
                ),
            ],
            onScanAnother: {},
            onConfirm: { _, _ in }
        )
    }
}
