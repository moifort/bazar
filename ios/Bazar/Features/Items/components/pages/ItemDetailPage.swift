import SwiftUI

struct ItemDetailPage: View {
    let id: String
    let name: String
    let description: String
    let category: ItemCategory
    let quantity: Int
    let imageURL: URL?
    let locationPath: String?
    let addedBy: String
    let personalNotes: String
    let createdAt: Date
    let updatedAt: Date

    let onRefresh: () async -> Void
    let onDelete: () async -> Void
    let onEditSave: (ItemEditForm.Fields) async throws -> Void

    @State private var showDeleteConfirmation = false
    @State private var isEditing = false

    var body: some View {
        Group {
            if isEditing {
                ItemEditForm(
                    initial: editFields,
                    onSave: { fields in
                        try await onEditSave(fields)
                        isEditing = false
                    },
                    onCancel: { isEditing = false }
                )
            } else {
                itemContent
                    .refreshable { await onRefresh() }
            }
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            if !isEditing {
                readToolbar
            }
        }
        .confirmationDialog(
            "Supprimer cet objet ?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                Task { await onDelete() }
            }
        }
    }

    private var editFields: ItemEditForm.Fields {
        .init(
            name: name,
            description: description,
            category: category,
            quantity: quantity,
            notes: personalNotes
        )
    }

    @ViewBuilder
    private var itemContent: some View {
        List {
            if let imageURL {
                Section {
                    AsyncImage(url: imageURL) { phase in
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
                LabeledContent("Catégorie") {
                    Label(category.label, systemImage: category.icon)
                        .foregroundStyle(category.color)
                        .labelStyle(.titleAndIcon)
                }
                LabeledContent("Quantité", value: "\(quantity)")
                if let locationPath {
                    LabeledContent("Lieu", value: locationPath)
                }
                LabeledContent("Ajouté par", value: addedBy)
            }

            if !description.isEmpty {
                Section("Description") {
                    Text(description)
                        .font(.body)
                }
            }

            if !personalNotes.isEmpty {
                Section("Notes") {
                    Text(personalNotes)
                        .font(.body)
                }
            }

            Section("Dates") {
                LabeledInfoRow(
                    title: "Ajouté le",
                    value: createdAt.formatted(date: .abbreviated, time: .shortened),
                    icon: "calendar.badge.plus"
                )
                LabeledInfoRow(
                    title: "Modifié le",
                    value: updatedAt.formatted(date: .abbreviated, time: .shortened),
                    icon: "calendar.badge.clock"
                )
            }
        }
    }

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
}

#Preview("Loaded") {
    NavigationStack {
        ItemDetailPage(
            id: "i1",
            name: "Perceuse Bosch",
            description: "Perceuse visseuse sans fil 18V, deux batteries incluses.",
            category: .tools,
            quantity: 1,
            imageURL: nil,
            locationPath: "Maison > Garage > Établi > Tiroir 1",
            addedBy: "Thibaut",
            personalNotes: "Batterie à remplacer bientôt",
            createdAt: .now.addingTimeInterval(-86_400 * 30),
            updatedAt: .now.addingTimeInterval(-3600),
            onRefresh: {},
            onDelete: {},
            onEditSave: { _ in }
        )
    }
}

#Preview("Minimal") {
    NavigationStack {
        ItemDetailPage(
            id: "i2",
            name: "Ampoule LED",
            description: "",
            category: .electronics,
            quantity: 12,
            imageURL: nil,
            locationPath: nil,
            addedBy: "Thibaut",
            personalNotes: "",
            createdAt: .now,
            updatedAt: .now,
            onRefresh: {},
            onDelete: {},
            onEditSave: { _ in }
        )
    }
}
