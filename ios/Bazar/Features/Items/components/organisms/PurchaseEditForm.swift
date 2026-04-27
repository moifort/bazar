import SwiftUI

/// Standalone form for editing only the purchase fields of an item
/// (date, location). Presented as a sheet from the read-mode detail
/// view so users can add/update the purchase info without entering
/// the full edit mode.
struct PurchaseEditForm: View {
    let initial: Fields
    let purchaseLocationSuggestions: [String]
    let onSave: (Fields) async throws -> Void
    let onCancel: () -> Void

    @State private var hasPurchaseDate: Bool
    @State private var purchaseDate: Date
    @State private var purchaseLocation: String
    @State private var isSaving = false
    @State private var saveError: String?

    init(
        initial: Fields,
        purchaseLocationSuggestions: [String] = [],
        onSave: @escaping (Fields) async throws -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initial = initial
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
    }

    private var suggestionsToShow: [String] {
        guard purchaseLocation.count < 30 else { return [] }
        let trimmed = purchaseLocation.trimmingCharacters(in: .whitespaces)
        return purchaseLocationSuggestions
            .filter { $0 != trimmed && (trimmed.isEmpty || $0.localizedCaseInsensitiveContains(trimmed)) }
            .prefix(3)
            .map { $0 }
    }

    private func save() async {
        isSaving = true
        let fields = Fields(
            purchaseDate: hasPurchaseDate ? purchaseDate : nil,
            purchaseLocation: purchaseLocation.trimmingCharacters(in: .whitespaces)
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
    }
}

#Preview("Empty") {
    NavigationStack {
        PurchaseEditForm(
            initial: .init(
                purchaseDate: nil,
                purchaseLocation: ""
            ),
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
                purchaseLocation: "Amazon"
            ),
            purchaseLocationSuggestions: ["Amazon", "Leroy Merlin"],
            onSave: { _ in },
            onCancel: {}
        )
    }
}
