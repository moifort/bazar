import PhotosUI
import SwiftUI

/// Standalone form for editing only the purchase fields of an item
/// (date, location, invoice photo). Presented as a sheet from the
/// read-mode detail view so users can add/update the purchase info
/// without entering the full edit mode.
struct PurchaseEditForm: View {
    let initial: Fields
    let existingInvoiceImageURL: URL?
    let purchaseLocationSuggestions: [String]
    let onSave: (Fields) async throws -> Void
    let onCancel: () -> Void

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
        _hasPurchaseDate = State(initialValue: initial.purchaseDate != nil)
        _purchaseDate = State(initialValue: initial.purchaseDate ?? Date())
        _purchaseLocation = State(initialValue: initial.purchaseLocation)
    }

    var body: some View {
        Form {
            Section("Date & lieu") {
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
            }

            Section("Facture") {
                invoiceRow
            }
        }
        .navigationTitle("Achat")
        .navigationBarTitleDisplayMode(.inline)
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

extension PurchaseEditForm {
    struct Fields: Sendable {
        var purchaseDate: Date?
        var purchaseLocation: String
        /// nil = no change, "" = clear, non-empty = replace with this base64 photo.
        var invoiceImageBase64Update: String?
    }
}

#Preview("Empty") {
    NavigationStack {
        PurchaseEditForm(
            initial: .init(
                purchaseDate: nil,
                purchaseLocation: "",
                invoiceImageBase64Update: nil
            ),
            existingInvoiceImageURL: nil,
            purchaseLocationSuggestions: ["Amazon", "Leroy Merlin", "Castorama"],
            onSave: { _ in },
            onCancel: {}
        )
    }
}

#Preview("Prefilled") {
    NavigationStack {
        PurchaseEditForm(
            initial: .init(
                purchaseDate: Date(timeIntervalSinceNow: -86_400 * 30),
                purchaseLocation: "Amazon",
                invoiceImageBase64Update: nil
            ),
            existingInvoiceImageURL: nil,
            purchaseLocationSuggestions: ["Amazon", "Leroy Merlin"],
            onSave: { _ in },
            onCancel: {}
        )
    }
}
