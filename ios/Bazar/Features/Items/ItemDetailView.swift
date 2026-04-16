import Apollo
import SwiftUI

struct ItemDetailView: View {
    let itemId: String
    var onDeleted: () -> Void = {}
    var onUpdated: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var item: Item?
    @State private var errorMessage: String?
    @State private var purchaseLocationSuggestions: [String] = []

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
                    addedBy: item.addedBy,
                    personalNotes: item.personalNotes,
                    purchaseDate: item.purchaseDate,
                    purchaseLocation: item.purchaseLocation,
                    invoiceImageURL: item.invoiceImageId.flatMap(imageURL(for:)),
                    purchaseLocationSuggestions: purchaseLocationSuggestions,
                    onRefresh: { await loadDetail() },
                    onDelete: { await deleteItem() },
                    onEditSave: { fields in
                        try await saveItem(fields)
                        onUpdated()
                    }
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
