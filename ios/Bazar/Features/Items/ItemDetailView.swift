import SwiftUI

struct ItemDetailView: View {
    let itemId: String
    var onDeleted: () -> Void = {}
    var onUpdated: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var item: Item?
    @State private var errorMessage: String?

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
                    onRefresh: { await loadDetail() },
                    onDelete: { await deleteItem() },
                    onEditSave: { _ in
                        try await saveItem()
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
        .task { await loadDetail() }
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

    private func deleteItem() async {
        do {
            try await GraphQLItemsAPI.delete(id: itemId)
            onDeleted()
            dismiss()
        } catch {
            errorMessage = reportError(error)
        }
    }

    private func saveItem() async throws {
        item = try await GraphQLItemsAPI.getDetail(id: itemId)
    }
}
