import Apollo
import SwiftUI

struct ItemDetailView: View {
    let itemId: String
    var onDeleted: () -> Void = {}
    var onUpdated: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var item: Item?
    @State private var errorMessage: String?
    @State private var purchaseLocationSuggestions: [String] = []
    @State private var showReminders = false
    @State private var showMovePicker = false
    @State private var showPurchaseEdit = false
    @State private var showLowStockEdit = false
    @State private var pendingLocation: LocationSelection = .none
    @State private var isMoving = false

    var body: some View {
        Group {
            if let item {
                ItemDetailPage(
                    id: item.id,
                    name: item.name,
                    description: item.description,
                    category: item.category,
                    quantity: item.quantity,
                    location: item.location,
                    personalNotes: item.personalNotes,
                    createdAt: item.createdAt,
                    purchaseDate: item.purchaseDate,
                    purchaseLocation: item.purchaseLocation,
                    purchaseCondition: item.purchaseCondition,
                    lowStockThreshold: item.lowStockThreshold,
                    purchaseLocationSuggestions: purchaseLocationSuggestions,
                    reminders: item.reminders.map(ReminderRowMapper.map),
                    onRefresh: { await loadDetail() },
                    onDelete: { await deleteItem() },
                    onEditSave: { fields in
                        try await saveItem(fields)
                        onUpdated()
                    },
                    onOpenReminders: { showReminders = true },
                    onOpenMove: {
                        pendingLocation = currentLocationSelection(for: item)
                        showMovePicker = true
                    },
                    onOpenPurchaseEdit: { showPurchaseEdit = true },
                    onOpenLowStockEdit: { showLowStockEdit = true },
                    onClose: { dismiss() }
                )
            } else if let errorMessage {
                ContentUnavailableView(
                    "Erreur",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else {
                ProgressView("Chargement...")
            }
        }
        .task {
            await loadDetail()
            await loadSuggestions()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await syncNotifications() }
            }
        }
        .sheet(isPresented: $showReminders) {
            if let item {
                NavigationStack {
                    ItemRemindersView(
                        itemId: item.id,
                        itemName: item.name,
                        onChanged: { Task { await loadDetail() } }
                    )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Fermer", systemImage: "xmark") { showReminders = false }
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showMovePicker, onDismiss: {
            guard let item else { return }
            let current = currentLocationSelection(for: item)
            if pendingLocation != current {
                let target = pendingLocation
                Task { await moveItem(to: target) }
            }
        }) {
            LocationPicker(selection: $pendingLocation)
        }
        .sheet(isPresented: $showPurchaseEdit) {
            if let item {
                NavigationStack {
                    PurchaseEditForm(
                        initial: .init(
                            purchaseDate: item.purchaseDate,
                            purchaseLocation: item.purchaseLocation,
                            purchaseCondition: item.purchaseCondition
                        ),
                        purchaseLocationSuggestions: purchaseLocationSuggestions,
                        onSave: { fields in
                            try await savePurchase(fields)
                            showPurchaseEdit = false
                            onUpdated()
                        },
                        onCancel: { showPurchaseEdit = false }
                    )
                }
            }
        }
        .sheet(isPresented: $showLowStockEdit) {
            if let item {
                NavigationStack {
                    LowStockEditForm(
                        initial: item.lowStockThreshold,
                        onSave: { threshold in
                            try await saveLowStockThreshold(threshold)
                            showLowStockEdit = false
                            onUpdated()
                        },
                        onCancel: { showLowStockEdit = false }
                    )
                }
            }
        }
        .overlay {
            if isMoving {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView("Déplacement…")
                        .padding(24)
                        .background(.regularMaterial, in: .rect(cornerRadius: 12))
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isMoving)
    }

    private func syncNotifications() async {
        guard let item else { return }
        await NotificationManager.syncAll(
            reminders: item.reminders,
            itemNames: [item.id: item.name]
        )
    }

    private func loadDetail() async {
        errorMessage = nil
        do {
            item = try await GraphQLItemsAPI.getDetail(id: itemId)
        } catch {
            errorMessage = reportError(error)
        }
    }

    private func loadSuggestions() async {
        purchaseLocationSuggestions = (try? await GraphQLItemsAPI.distinctPurchaseLocations()) ?? []
    }

    private func deleteItem() async {
        do {
            try await GraphQLItemsAPI.delete(id: itemId)
            onDeleted()
            dismiss()
        } catch {
            errorMessage = reportError(error)
        }
    }

    private func moveItem(to target: LocationSelection) async {
        isMoving = true
        defer { isMoving = false }
        do {
            try await GraphQLItemsAPI.move(id: itemId, target: target)
            item = try await GraphQLItemsAPI.getDetail(id: itemId)
            onUpdated()
        } catch {
            errorMessage = reportError(error)
        }
    }

    private func currentLocationSelection(for item: Item) -> LocationSelection {
        if let storageId = item.location?.storageId {
            return .storage(id: storageId)
        }
        if let zoneId = item.location?.zoneId, item.location?.storageId == nil {
            return .zone(id: zoneId)
        }
        return .none
    }

    private func saveItem(_ fields: ItemEditForm.Fields) async throws {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        nonisolated(unsafe) let input = BazarGraphQL.UpdateItemInput(
            category: .some(.case(BazarGraphQL.ItemCategory(rawValue: fields.category.rawValue) ?? .other)),
            description: .some(fields.description),
            name: .some(fields.name),
            personalNotes: .some(fields.notes),
            purchaseCondition: graphQLPurchaseCondition(fields.purchaseCondition),
            purchaseDate: fields.purchaseDate.map { .some(iso.string(from: $0)) } ?? .null,
            purchaseLocation: .some(fields.purchaseLocation),
            quantity: .some(String(fields.quantity))
        )
        try await GraphQLItemsAPI.update(id: itemId, input: input)
        item = try await GraphQLItemsAPI.getDetail(id: itemId)
    }

    private func saveLowStockThreshold(_ threshold: Int?) async throws {
        nonisolated(unsafe) let input = BazarGraphQL.UpdateItemInput(
            category: .none,
            description: .none,
            lowStockThreshold: threshold.map { .some($0) } ?? .null,
            name: .none,
            personalNotes: .none,
            purchaseCondition: .none,
            purchaseDate: .none,
            purchaseLocation: .none,
            quantity: .none
        )
        try await GraphQLItemsAPI.update(id: itemId, input: input)
        item = try await GraphQLItemsAPI.getDetail(id: itemId)
    }

    private func savePurchase(_ fields: PurchaseEditForm.Fields) async throws {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        nonisolated(unsafe) let input = BazarGraphQL.UpdateItemInput(
            category: .none,
            description: .none,
            name: .none,
            personalNotes: .none,
            purchaseCondition: graphQLPurchaseCondition(fields.purchaseCondition),
            purchaseDate: fields.purchaseDate.map { .some(iso.string(from: $0)) } ?? .null,
            purchaseLocation: .some(fields.purchaseLocation),
            quantity: .none
        )
        try await GraphQLItemsAPI.update(id: itemId, input: input)
        item = try await GraphQLItemsAPI.getDetail(id: itemId)
    }

    private func graphQLPurchaseCondition(
        _ condition: PurchaseCondition?
    ) -> GraphQLNullable<GraphQLEnum<BazarGraphQL.PurchaseCondition>> {
        guard let condition else { return .null }
        guard let value = BazarGraphQL.PurchaseCondition(rawValue: condition.rawValue) else {
            return .null
        }
        return .some(.case(value))
    }
}
