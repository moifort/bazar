import SwiftUI

struct ItemEditForm: View {
    let initial: Fields
    let onSave: (Fields) async throws -> Void
    let onCancel: () -> Void

    @State private var name: String
    @State private var description: String
    @State private var category: ItemCategory
    @State private var quantity: Int
    @State private var notes: String
    @State private var isSaving = false
    @State private var saveError: String?

    init(
        initial: Fields,
        onSave: @escaping (Fields) async throws -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initial = initial
        self.onSave = onSave
        self.onCancel = onCancel
        _name = State(initialValue: initial.name)
        _description = State(initialValue: initial.description)
        _category = State(initialValue: initial.category)
        _quantity = State(initialValue: initial.quantity)
        _notes = State(initialValue: initial.notes)
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

                Stepper(value: $quantity, in: 1...9999) {
                    Label {
                        LabeledContent("Quantité", value: "\(quantity)")
                    } icon: {
                        Image(systemName: "number")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Description") {
                TextField("Description de l'objet", text: $description, axis: .vertical)
                    .lineLimit(3...8)
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
                .disabled(isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                if isSaving {
                    ProgressView()
                } else {
                    Button("Enregistrer", systemImage: "checkmark") {
                        Task { await save() }
                    }
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
    }

    private func save() async {
        isSaving = true
        let fields = Fields(
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            category: category,
            quantity: quantity,
            notes: notes.trimmingCharacters(in: .whitespaces)
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

        init(
            name: String,
            description: String,
            category: ItemCategory,
            quantity: Int,
            notes: String
        ) {
            self.name = name
            self.description = description
            self.category = category
            self.quantity = quantity
            self.notes = notes
        }

        init(from item: Item) {
            self.init(
                name: item.name,
                description: item.description,
                category: item.category,
                quantity: item.quantity,
                notes: item.personalNotes
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
                notes: "Batterie à remplacer"
            ),
            onSave: { _ in },
            onCancel: {}
        )
    }
}
