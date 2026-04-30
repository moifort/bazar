import SwiftUI

/// Standalone form for editing the low-stock alert threshold of an item.
/// Presented as a sheet from the read-mode detail view. Returns `nil` when
/// the alert is disabled, otherwise the threshold quantity.
struct LowStockEditForm: View {
    let initial: Int?
    let onSave: (Int?) async throws -> Void
    let onCancel: () -> Void

    @State private var isEnabled: Bool
    @State private var threshold: Int
    @State private var isSaving = false
    @State private var saveError: String?

    init(
        initial: Int?,
        onSave: @escaping (Int?) async throws -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initial = initial
        self.onSave = onSave
        self.onCancel = onCancel
        _isEnabled = State(initialValue: initial != nil)
        _threshold = State(initialValue: initial ?? 2)
    }

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $isEnabled) {
                    Label("Activer l'alerte de stock bas", systemImage: "bell.badge.waveform")
                }
                if isEnabled {
                    Stepper(value: $threshold, in: 1...999) {
                        LabeledContent("Seuil") {
                            Text("\(threshold)")
                                .monospacedDigit()
                                .foregroundStyle(.primary)
                        }
                    }
                }
            } header: {
                Text("Alerte stock")
            } footer: {
                Text(footerText)
            }
        }
        .navigationTitle("Alerte stock")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", systemImage: "xmark") { onCancel() }
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

    private var footerText: String {
        isEnabled
            ? "Vous recevrez une notification quand la quantité atteindra \(threshold) ou moins."
            : "Aucune notification ne sera envoyée pour cet objet."
    }

    private func save() async {
        isSaving = true
        do {
            try await onSave(isEnabled ? threshold : nil)
        } catch {
            saveError = reportError(error)
        }
        isSaving = false
    }
}

#Preview("Disabled") {
    NavigationStack {
        LowStockEditForm(initial: nil, onSave: { _ in }, onCancel: {})
    }
}

#Preview("Enabled") {
    NavigationStack {
        LowStockEditForm(initial: 2, onSave: { _ in }, onCancel: {})
    }
}
