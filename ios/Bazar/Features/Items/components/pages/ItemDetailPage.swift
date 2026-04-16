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
    let purchaseDate: Date?
    let purchaseLocation: String
    let invoiceImageURL: URL?
    let purchaseLocationSuggestions: [String]

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
                    existingInvoiceImageURL: invoiceImageURL,
                    purchaseLocationSuggestions: purchaseLocationSuggestions,
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
            notes: personalNotes,
            purchaseDate: purchaseDate,
            purchaseLocation: purchaseLocation,
            invoiceImageBase64Update: nil
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

            if purchaseDate != nil || !purchaseLocation.isEmpty || invoiceImageURL != nil {
                Section("Achat") {
                    if let purchaseDate {
                        LabeledContent("Date", value: purchaseDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    if !purchaseLocation.isEmpty {
                        if let url = locationURL(from: purchaseLocation) {
                            LabeledContent("Lieu") {
                                Link(purchaseLocation, destination: url)
                            }
                        } else {
                            LabeledContent("Lieu", value: purchaseLocation)
                        }
                    }
                    if let invoiceImageURL {
                        Link(destination: invoiceImageURL) {
                            Label("Voir la facture", systemImage: "doc.text.magnifyingglass")
                        }
                    }
                }
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
        }
    }

    private func locationURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard trimmed.contains("http") || trimmed.contains(".") && !trimmed.contains(" ") else {
            return nil
        }
        let candidate = trimmed.hasPrefix("http") ? trimmed : "https://\(trimmed)"
        guard let url = URL(string: candidate), url.host != nil else { return nil }
        return url
    }

    @ToolbarContentBuilder
    private var readToolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Modifier", systemImage: "pencil") {
                isEditing = true
            }
            .accessibilityIdentifier("edit-item-button")
        }
        ToolbarItem(placement: .secondaryAction) {
            Button("Supprimer", systemImage: "trash", role: .destructive) {
                showDeleteConfirmation = true
            }
            .accessibilityIdentifier("delete-item-button")
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
            purchaseDate: Date(timeIntervalSinceNow: -86_400 * 120),
            purchaseLocation: "amazon.fr",
            invoiceImageURL: nil,
            purchaseLocationSuggestions: ["Amazon", "Leroy Merlin"],
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
            purchaseDate: nil,
            purchaseLocation: "",
            invoiceImageURL: nil,
            purchaseLocationSuggestions: [],
            onRefresh: {},
            onDelete: {},
            onEditSave: { _ in }
        )
    }
}
