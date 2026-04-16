import PhotosUI
import SwiftUI

struct ItemEditForm: View {
    let initial: Fields
    let existingInvoiceImageURL: URL?
    let purchaseLocationSuggestions: [String]
    let onSave: (Fields) async throws -> Void
    let onCancel: () -> Void

    @State private var name: String
    @State private var description: String
    @State private var category: ItemCategory
    @State private var quantity: Int
    @State private var notes: String
    @State private var hasPurchaseDate: Bool
    @State private var purchaseDate: Date
    @State private var purchaseLocation: String
    @State private var invoicePhotoItem: PhotosPickerItem?
    @State private var pendingInvoiceBase64: String?
    @State private var invoiceCleared: Bool = false
    @State private var isSaving = false
    @State private var saveError: String?

    init(
        initial: Fields,
        existingInvoiceImageURL: URL? = nil,
        purchaseLocationSuggestions: [String] = [],
        onSave: @escaping (Fields) async throws -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initial = initial
        self.existingInvoiceImageURL = existingInvoiceImageURL
        self.purchaseLocationSuggestions = purchaseLocationSuggestions
        self.onSave = onSave
        self.onCancel = onCancel
        _name = State(initialValue: initial.name)
        _description = State(initialValue: initial.description)
        _category = State(initialValue: initial.category)
        _quantity = State(initialValue: initial.quantity)
        _notes = State(initialValue: initial.notes)
        _hasPurchaseDate = State(initialValue: initial.purchaseDate != nil)
        _purchaseDate = State(initialValue: initial.purchaseDate ?? Date())
        _purchaseLocation = State(initialValue: initial.purchaseLocation)
    }

    var body: some View {
        Form {
            Section("Informations principales") {
                LabeledContent {
                    TextField("Nom", text: $name)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("Nom", systemImage: "archivebox")
                }

                Picker(selection: $category) {
                    ForEach(ItemCategory.allCases) { cat in
                        Label(cat.label, systemImage: cat.icon).tag(cat)
                    }
                } label: {
                    Label("Catégorie", systemImage: "tag")
                }

                Stepper("Quantité : \(quantity)", value: $quantity, in: 1...9999)
            }

            Section("Description") {
                TextField("Description de l'objet", text: $description, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section("Achat") {
                Toggle(isOn: $hasPurchaseDate) {
                    Label("Date d'achat", systemImage: "calendar")
                }
                if hasPurchaseDate {
                    DatePicker(
                        "Date d'achat",
                        selection: $purchaseDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }

                LabeledContent {
                    TextField("Amazon, Leroy Merlin…", text: $purchaseLocation)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                } label: {
                    Label("Lieu", systemImage: "bag")
                }

                if !suggestionsToShow.isEmpty {
                    ForEach(suggestionsToShow, id: \.self) { suggestion in
                        Button {
                            purchaseLocation = suggestion
                        } label: {
                            Label(suggestion, systemImage: "arrow.up.left")
                                .labelStyle(.titleAndIcon)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                invoiceRow
            }

            Section("Notes") {
                TextField("Notes personnelles", text: $notes, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", systemImage: "xmark") {
                    onCancel()
                }
                .labelStyle(.iconOnly)
                .disabled(isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                if isSaving {
                    ProgressView()
                } else {
                    Button("Enregistrer", systemImage: "checkmark") {
                        Task { await save() }
                    }
                    .labelStyle(.iconOnly)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .alert("Erreur", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
        .onChange(of: invoicePhotoItem) { _, newItem in
            Task { await loadInvoiceData(from: newItem) }
        }
    }

    private var suggestionsToShow: [String] {
        guard purchaseLocation.count < 30 else { return [] }
        let trimmed = purchaseLocation.trimmingCharacters(in: .whitespaces)
        return purchaseLocationSuggestions
            .filter { $0 != trimmed && (trimmed.isEmpty || $0.localizedCaseInsensitiveContains(trimmed)) }
            .prefix(3)
            .map { $0 }
    }

    @ViewBuilder
    private var invoiceRow: some View {
        if pendingInvoiceBase64 != nil {
            LabeledContent {
                Button("Annuler", role: .destructive) {
                    pendingInvoiceBase64 = nil
                    invoicePhotoItem = nil
                }
            } label: {
                Label("Nouvelle facture prête", systemImage: "doc.badge.plus")
                    .foregroundStyle(.green)
            }
        } else if let existingInvoiceImageURL, !invoiceCleared {
            LabeledContent {
                HStack {
                    AsyncImage(url: existingInvoiceImageURL) { phase in
                        if case .success(let image) = phase {
                            image.resizable().aspectRatio(contentMode: .fit).frame(height: 32)
                        } else {
                            Image(systemName: "doc").foregroundStyle(.secondary)
                        }
                    }
                    Button("Supprimer", role: .destructive) { invoiceCleared = true }
                        .buttonStyle(.borderless)
                }
            } label: {
                Label("Facture", systemImage: "doc.text")
            }
        } else {
            PhotosPicker(
                selection: $invoicePhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Ajouter une photo de la facture", systemImage: "doc.badge.plus")
            }
        }
    }

    private func loadInvoiceData(from item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            pendingInvoiceBase64 = data.base64EncodedString()
            invoiceCleared = false
        }
    }

    private func save() async {
        isSaving = true
        let invoiceUpdate: String?
        if let pendingInvoiceBase64 {
            invoiceUpdate = pendingInvoiceBase64
        } else if invoiceCleared {
            invoiceUpdate = ""
        } else {
            invoiceUpdate = nil
        }
        let fields = Fields(
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            category: category,
            quantity: quantity,
            notes: notes.trimmingCharacters(in: .whitespaces),
            purchaseDate: hasPurchaseDate ? purchaseDate : nil,
            purchaseLocation: purchaseLocation.trimmingCharacters(in: .whitespaces),
            invoiceImageBase64Update: invoiceUpdate
        )
        do {
            try await onSave(fields)
        } catch {
            saveError = reportError(error)
        }
        isSaving = false
    }
}

extension ItemEditForm {
    struct Fields: Sendable {
        var name: String
        var description: String
        var category: ItemCategory
        var quantity: Int
        var notes: String
        var purchaseDate: Date?
        var purchaseLocation: String
        /// nil = no change, "" = clear, non-empty = replace with this base64 photo.
        var invoiceImageBase64Update: String?

        init(
            name: String,
            description: String,
            category: ItemCategory,
            quantity: Int,
            notes: String,
            purchaseDate: Date? = nil,
            purchaseLocation: String = "",
            invoiceImageBase64Update: String? = nil
        ) {
            self.name = name
            self.description = description
            self.category = category
            self.quantity = quantity
            self.notes = notes
            self.purchaseDate = purchaseDate
            self.purchaseLocation = purchaseLocation
            self.invoiceImageBase64Update = invoiceImageBase64Update
        }

        init(from item: Item) {
            self.init(
                name: item.name,
                description: item.description,
                category: item.category,
                quantity: item.quantity,
                notes: item.personalNotes,
                purchaseDate: item.purchaseDate,
                purchaseLocation: item.purchaseLocation,
                invoiceImageBase64Update: nil
            )
        }
    }
}

#Preview {
    NavigationStack {
        ItemEditForm(
            initial: .init(
                name: "Perceuse Bosch",
                description: "Perceuse visseuse sans fil 18V",
                category: .tools,
                quantity: 1,
                notes: "Batterie à remplacer",
                purchaseDate: Date(timeIntervalSinceNow: -86_400 * 30),
                purchaseLocation: "Amazon"
            ),
            existingInvoiceImageURL: nil,
            purchaseLocationSuggestions: ["Amazon", "Leroy Merlin", "Castorama"],
            onSave: { _ in },
            onCancel: {}
        )
    }
}
