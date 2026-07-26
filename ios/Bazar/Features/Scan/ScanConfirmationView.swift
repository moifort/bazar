import SwiftUI

/// Connected container for the scan confirmation step.
/// Owns the editable preview list, location selection, LocationPicker sheet,
/// async confirm action, breadcrumb resolution and the per-item details sheet.
/// Renders through the pure `ScanConfirmationPage` view.
struct ScanConfirmationView: View {
    let previews: [ItemPreview]
    let onScanAnother: () -> Void
    let onConfirm: ([ItemPreview], LocationSelection) async -> Void
    let onClose: () -> Void

    @State private var editablePreviews: [EditablePreview]
    @State private var selection: LocationSelection
    @State private var showLocationPicker = false
    @State private var detailsTargetId: String?
    @State private var isConfirming = false
    @State private var places: [Place] = []
    @State private var purchaseLocationSuggestions: [String] = []
    @FocusState private var focused: ItemPreviewField?

    init(
        previews: [ItemPreview],
        onScanAnother: @escaping () -> Void,
        onConfirm: @escaping ([ItemPreview], LocationSelection) async -> Void,
        onClose: @escaping () -> Void
    ) {
        self.previews = previews
        self.onScanAnother = onScanAnother
        self.onConfirm = onConfirm
        self.onClose = onClose
        _editablePreviews = State(initialValue: previews.map { EditablePreview(from: $0) })
        _selection = State(initialValue: Self.loadLastSelection())
    }

    var body: some View {
        ScanConfirmationPage(
            previews: $editablePreviews,
            storageName: resolvedLocation?.name,
            breadcrumb: resolvedLocation?.breadcrumb,
            isConfirming: isConfirming,
            focus: $focused,
            onOpenLocationPicker: { showLocationPicker = true },
            onAdd: addItem,
            onEditDetails: { id in detailsTargetId = id },
            onDuplicate: duplicate(id:),
            onDelete: delete(id:),
            onScanAnother: onScanAnother,
            onConfirm: { Task { await confirm() } },
            onClose: onClose
        )
        .sheet(isPresented: $showLocationPicker) {
            LocationPicker(selection: $selection)
        }
        .sheet(item: detailsBinding) { target in
            ScanItemDetailsSheet(
                preview: target.preview,
                purchaseLocationSuggestions: purchaseLocationSuggestions,
                onSave: { updated in
                    if let index = editablePreviews.firstIndex(where: { $0.id == target.id }) {
                        editablePreviews[index] = updated
                    }
                    detailsTargetId = nil
                },
                onCancel: { detailsTargetId = nil }
            )
        }
        .task {
            await loadPlaces()
            await loadSuggestions()
        }
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
        let original = editablePreviews[index]
        let copy = EditablePreview(
            id: UUID().uuidString,
            name: original.name,
            category: original.category,
            description: original.description,
            quantity: original.quantity,
            tags: original.tags,
            personalNotes: original.personalNotes,
            purchaseDate: original.purchaseDate,
            purchaseLocation: original.purchaseLocation,
            purchaseCondition: original.purchaseCondition
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
        Self.persistSelection(selection)
        await onConfirm(items, selection)
        isConfirming = false
    }

    private func autoFocusIfSingle() {
        guard editablePreviews.count == 1, let first = editablePreviews.first else { return }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 250_000_000)
            focused = .name(first.id)
        }
    }

    // MARK: - Sheet binding

    private var detailsBinding: Binding<DetailsTarget?> {
        Binding(
            get: {
                guard let id = detailsTargetId,
                      let preview = editablePreviews.first(where: { $0.id == id })
                else { return nil }
                return DetailsTarget(id: id, preview: preview)
            },
            set: { newValue in
                if newValue == nil { detailsTargetId = nil }
            }
        )
    }

    // MARK: - Loading

    private func loadPlaces() async {
        do {
            places = try await GraphQLLocationsAPI.allPlaces()
        } catch {
            // Silent failure: the header card gracefully falls back to the
            // default "Choisir un emplacement" prompt when no location resolves.
        }
    }

    private func loadSuggestions() async {
        purchaseLocationSuggestions = (try? await GraphQLItemsAPI.distinctPurchaseLocations()) ?? []
    }

    // MARK: - Resolution

    private var resolvedLocation: (name: String, breadcrumb: String)? {
        switch selection {
        case .none:
            return nil
        case .storage(let storageId):
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
        case .zone(let zoneId):
            for place in places {
                for room in place.rooms {
                    if let zone = room.zones.first(where: { $0.id == zoneId }) {
                        let breadcrumb = "\(place.name) · \(room.name)"
                        return (zone.name, breadcrumb)
                    }
                }
            }
            return nil
        }
    }

    // MARK: - Persistence

    private static let storageKey = "lastLocationSelection"

    private static func loadLastSelection() -> LocationSelection {
        guard let raw = UserDefaults.standard.string(forKey: storageKey) else { return .none }
        let parts = raw.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return .none }
        switch parts[0] {
        case "zone": return .zone(id: parts[1])
        case "storage": return .storage(id: parts[1])
        default: return .none
        }
    }

    private static func persistSelection(_ selection: LocationSelection) {
        switch selection {
        case .none:
            UserDefaults.standard.removeObject(forKey: storageKey)
        case .zone(let id):
            UserDefaults.standard.set("zone:\(id)", forKey: storageKey)
        case .storage(let id):
            UserDefaults.standard.set("storage:\(id)", forKey: storageKey)
        }
    }
}

private struct DetailsTarget: Identifiable {
    let id: String
    let preview: EditablePreview
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
            onConfirm: { _, _ in },
            onClose: {}
        )
    }
}
