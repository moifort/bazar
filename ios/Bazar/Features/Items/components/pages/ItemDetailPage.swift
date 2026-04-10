import SwiftUI

struct ItemDetailPage: View {
    let itemId: String
    var onDeleted: () -> Void = {}
    var onUpdated: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var item: Item?
    @State private var error: String?
    @State private var showDeleteConfirmation = false
    @State private var isEditing = false

    var body: some View {
        Group {
            if let item {
                if isEditing {
                    ItemEditForm(
                        initial: ItemEditForm.Fields(from: item),
                        onSave: { fields in
                            // Will be wired to real API later
                            self.item = try await ItemsAPI.getDetail(id: itemId)
                            isEditing = false
                            onUpdated()
                        },
                        onCancel: { isEditing = false }
                    )
                } else {
                    itemContent(item)
                        .refreshable { await loadDetail() }
                }
            } else if let error {
                ContentUnavailableView(
                    "Erreur",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else {
                ProgressView("Chargement...")
            }
        }
        .navigationTitle(item?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            if item != nil && !isEditing {
                readToolbar
            }
        }
        .task { await loadDetail() }
        .confirmationDialog(
            "Supprimer cet objet ?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                Task { await deleteItem() }
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func itemContent(_ item: Item) -> some View {
        List {
            if let imageId = item.photoImageId {
                Section {
                    AsyncImage(url: imageURL(for: imageId)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 300)
                                .clipShape(.rect(cornerRadius: 12))
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 100)
                        default:
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 100)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }

            Section("Informations") {
                LabeledInfoRow(title: "Catégorie", value: item.category.label, icon: item.category.icon)
                LabeledInfoRow(title: "Quantité", value: "\(item.quantity)", icon: "number")
                if let location = item.location {
                    LabeledInfoRow(title: "Lieu", value: location.fullPath, icon: "mappin.and.ellipse")
                }
                LabeledInfoRow(title: "Ajouté par", value: item.addedBy, icon: "person")
            }

            if !item.description.isEmpty {
                Section("Description") {
                    Text(item.description)
                        .font(.body)
                }
            }

            if !item.personalNotes.isEmpty {
                Section("Notes") {
                    Text(item.personalNotes)
                        .font(.body)
                }
            }

            Section("Dates") {
                LabeledInfoRow(
                    title: "Ajouté le",
                    value: item.createdAt.formatted(date: .abbreviated, time: .shortened),
                    icon: "calendar.badge.plus"
                )
                LabeledInfoRow(
                    title: "Modifié le",
                    value: item.updatedAt.formatted(date: .abbreviated, time: .shortened),
                    icon: "calendar.badge.clock"
                )
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var readToolbar: some ToolbarContent {
        ToolbarItemGroup {
            Menu {
                Button("Modifier", systemImage: "pencil") {
                    isEditing = true
                }
                Button("Supprimer", systemImage: "trash", role: .destructive) {
                    showDeleteConfirmation = true
                }
                .accessibilityIdentifier("delete-item-button")
            } label: {
                Image(systemName: "ellipsis")
            }
            .accessibilityIdentifier("item-detail-menu")
        }
    }

    // MARK: - Helpers

    private func imageURL(for imageId: String) -> URL? {
        APIClient.shared.baseURL.appendingPathComponent("/images/\(imageId)")
    }

    private func loadDetail() async {
        error = nil
        do {
            item = try await ItemsAPI.getDetail(id: itemId)
        } catch {
            self.error = reportError(error)
        }
    }

    private func deleteItem() async {
        do {
            try await ItemsAPI.delete(id: itemId)
            onDeleted()
            dismiss()
        } catch {
            self.error = reportError(error)
        }
    }
}

#Preview {
    NavigationStack {
        ItemDetailPage(itemId: "preview-1")
    }
}
