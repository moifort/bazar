import SwiftUI

struct ScanConfirmationView: View {
    let previews: [ItemPreview]
    let onScanAnother: () -> Void
    let onConfirm: ([ItemPreview], String?) async -> Void

    @State private var editablePreviews: [EditablePreview]
    @State private var selectedStorageId: String?
    @State private var showLocationPicker = false
    @State private var isConfirming = false

    init(
        previews: [ItemPreview],
        onScanAnother: @escaping () -> Void,
        onConfirm: @escaping ([ItemPreview], String?) async -> Void
    ) {
        self.previews = previews
        self.onScanAnother = onScanAnother
        self.onConfirm = onConfirm
        _editablePreviews = State(initialValue: previews.map { EditablePreview(from: $0) })
        _selectedStorageId = State(
            initialValue: UserDefaults.standard.string(forKey: "lastStorageId")
        )
    }

    var body: some View {
        Form {
            Section {
                if editablePreviews.isEmpty {
                    ContentUnavailableView(
                        "Aucun objet détecté",
                        systemImage: "viewfinder",
                        description: Text("Essayez de scanner à nouveau")
                    )
                } else {
                    ForEach($editablePreviews) { $preview in
                        VStack(alignment: .leading, spacing: 8) {
                            LabeledContent {
                                TextField("Nom", text: $preview.name)
                                    .multilineTextAlignment(.trailing)
                            } label: {
                                Label("Nom", systemImage: "archivebox")
                            }

                            Picker(selection: $preview.category) {
                                Text("Non définie").tag(nil as ItemCategory?)
                                ForEach(ItemCategory.allCases) { cat in
                                    Label(cat.label, systemImage: cat.icon).tag(cat as ItemCategory?)
                                }
                            } label: {
                                Label("Catégorie", systemImage: "tag")
                            }

                            Stepper("Quantité : \(preview.quantity)", value: $preview.quantity, in: 1...9999)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                editablePreviews.removeAll { $0.id == preview.id }
                            } label: {
                                Label("Retirer", systemImage: "minus.circle")
                            }
                        }
                    }
                }
            } header: {
                Text("\(editablePreviews.count) \(editablePreviews.count <= 1 ? "objet détecté" : "objets détectés")")
            }

            Section("Rangement") {
                Button {
                    showLocationPicker = true
                } label: {
                    LabeledContent("Emplacement", value: selectedStorageId ?? "Non défini")
                }
                .tint(.primary)
            }
        }
        .navigationTitle("Vérifier les objets")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Scanner à nouveau", systemImage: "camera") {
                    onScanAnother()
                }
                .labelStyle(.iconOnly)
                .accessibilityIdentifier("scan-another-button")
            }

            ToolbarItem(placement: .confirmationAction) {
                if isConfirming {
                    ProgressView()
                } else {
                    Button("Confirmer", systemImage: "checkmark") {
                        Task { await confirm() }
                    }
                    .labelStyle(.iconOnly)
                    .disabled(editablePreviews.isEmpty)
                    .accessibilityIdentifier("confirm-items-button")
                }
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPicker(selectedStorageId: $selectedStorageId)
        }
    }

    private func confirm() async {
        isConfirming = true
        let items = editablePreviews.map { $0.toPreview() }
        if let storageId = selectedStorageId {
            UserDefaults.standard.set(storageId, forKey: "lastStorageId")
        }
        await onConfirm(items, selectedStorageId)
        isConfirming = false
    }
}

#Preview {
    NavigationStack {
        ScanConfirmationView(
            previews: [
                ItemPreview(
                    previewId: "1",
                    name: "Perceuse Bosch",
                    category: .tools,
                    description: "Perceuse visseuse 18V",
                    quantity: 1
                ),
                ItemPreview(
                    previewId: "2",
                    name: "Tournevis",
                    category: .tools,
                    description: "",
                    quantity: 3
                ),
            ],
            onScanAnother: {},
            onConfirm: { _, _ in }
        )
    }
}
