import SwiftUI

struct AddLocationSheet: View {
    let title: String
    let placeholder: String
    let onSave: (String) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isSaving = false
    @FocusState private var nameFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                TextField(placeholder, text: $name)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit { Task { await save() } }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Ajouter") { Task { await save() } }
                            .disabled(trimmed.isEmpty)
                    }
                }
            }
            .task { nameFocused = true }
        }
        .presentationDetents([.medium])
    }

    private var trimmed: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func save() async {
        let value = trimmed
        guard !value.isEmpty else { return }
        isSaving = true
        await onSave(value)
        isSaving = false
        dismiss()
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            AddLocationSheet(
                title: "Nouvelle pièce",
                placeholder: "Nom de la pièce",
                onSave: { _ in try? await Task.sleep(for: .seconds(1)) }
            )
        }
}
