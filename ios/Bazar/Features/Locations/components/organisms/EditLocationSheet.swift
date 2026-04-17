import SwiftUI

struct EditLocationSheet: View {
    let title: String
    let placeholder: String
    let initialName: String
    let initialIcon: String?
    let showIconField: Bool
    let onSave: (_ name: String, _ icon: String?) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var icon: String
    @State private var isSaving = false
    @FocusState private var nameFocused: Bool

    init(
        title: String,
        placeholder: String,
        initialName: String,
        initialIcon: String? = nil,
        showIconField: Bool = false,
        onSave: @escaping (_ name: String, _ icon: String?) async -> Void
    ) {
        self.title = title
        self.placeholder = placeholder
        self.initialName = initialName
        self.initialIcon = initialIcon
        self.showIconField = showIconField
        self.onSave = onSave
        _name = State(initialValue: initialName)
        _icon = State(initialValue: initialIcon ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(placeholder, text: $name)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit { Task { await save() } }

                if showIconField {
                    TextField("Emoji (optionnel)", text: $icon)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler", systemImage: "xmark") { dismiss() }
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
                        .disabled(trimmedName.isEmpty)
                    }
                }
            }
            .task { nameFocused = true }
        }
        .presentationDetents([.medium])
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private var trimmedIcon: String? {
        let value = icon.trimmingCharacters(in: .whitespaces)
        return value.isEmpty ? nil : value
    }

    private func save() async {
        let value = trimmedName
        guard !value.isEmpty else { return }
        isSaving = true
        await onSave(value, showIconField ? trimmedIcon : nil)
        isSaving = false
        dismiss()
    }
}

#Preview("Rename zone") {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            EditLocationSheet(
                title: "Modifier la zone",
                placeholder: "Nom de la zone",
                initialName: "Établi",
                onSave: { _, _ in try? await Task.sleep(for: .seconds(1)) }
            )
        }
}

#Preview("Rename place with icon") {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            EditLocationSheet(
                title: "Modifier le lieu",
                placeholder: "Nom du lieu",
                initialName: "Maison",
                initialIcon: "🏠",
                showIconField: true,
                onSave: { _, _ in try? await Task.sleep(for: .seconds(1)) }
            )
        }
}
