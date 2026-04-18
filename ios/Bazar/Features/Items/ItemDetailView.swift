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

    var body: some View {
        Group {
            if let item {
                ItemDetailPage(
                    id: item.id,
                    name: item.name,
                    description: item.description,
                    category: item.category,
                    quantity: item.quantity,
                    imageURL: item.photoImageId.flatMap(imageURL(for:)),
                    locationPath: item.location?.fullPath,
                    personalNotes: item.personalNotes,
                    purchaseDate: item.purchaseDate,
                    purchaseLocation: item.purchaseLocation,
                    invoiceImageURL: item.invoiceImageId.flatMap(imageURL(for:)),
                    purchaseLocationSuggestions: purchaseLocationSuggestions,
                    reminders: item.reminders.map(ReminderRowMapper.map),
                    onRefresh: { await loadDetail() },
                    onDelete: { await deleteItem() },
                    onEditSave: { fields in
                        try await saveItem(fields)
                        onUpdated()
                    },
                    onOpenReminders: { showReminders = true }
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
    }

    private func syncNotifications() async {
        guard let item else { return }
        await NotificationManager.syncAll(
            reminders: item.reminders,
            itemNames: [item.id: item.name]
        )
    }

    private func imageURL(for imageId: String) -> URL? {
        APIClient.shared.baseURL.appendingPathComponent("/images/\(imageId)")
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

    private func saveItem(_ fields: ItemEditForm.Fields) async throws {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        nonisolated(unsafe) let input = BazarGraphQL.UpdateItemInput(
            category: .some(.case(BazarGraphQL.ItemCategory(rawValue: fields.category.rawValue) ?? .other)),
            description: .some(fields.description),
            invoiceImageBase64: fields.invoiceImageBase64Update.map { .some($0) } ?? .none,
            name: .some(fields.name),
            personalNotes: .some(fields.notes),
            purchaseDate: fields.purchaseDate.map { .some(iso.string(from: $0)) } ?? .null,
            purchaseLocation: .some(fields.purchaseLocation),
            quantity: .some(String(fields.quantity))
        )
        try await GraphQLItemsAPI.update(id: itemId, input: input)
        item = try await GraphQLItemsAPI.getDetail(id: itemId)
    }
}
