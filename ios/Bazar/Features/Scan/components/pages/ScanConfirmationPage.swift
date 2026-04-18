import SwiftUI

/// Pure presentation layer of the scan confirmation screen.
/// Receives all state via bindings / simple values and forwards user intents
/// through callbacks. The connected layer (`ScanConfirmationView`) is
/// responsible for loading places, presenting the LocationPicker sheet and
/// running the async confirm mutation.
struct ScanConfirmationPage: View {
    @Binding var previews: [EditablePreview]
    let storageName: String?
    let breadcrumb: String?
    let isConfirming: Bool
    var focus: FocusState<ItemPreviewField?>.Binding
    let onOpenLocationPicker: () -> Void
    let onAdd: () -> Void
    let onDuplicate: (String) -> Void
    let onDelete: (String) -> Void
    let onScanAnother: () -> Void
    let onConfirm: () -> Void
    let onClose: () -> Void

    @State private var showCloseConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                listHeader

                if previews.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach($previews) { $preview in
                            ItemPreviewCard(
                                preview: $preview,
                                focus: focus,
                                onSubmit: { focusNext(after: preview.id) },
                                onDuplicate: { onDuplicate(preview.id) },
                                onDelete: { onDelete(preview.id) }
                            )
                            .transition(
                                .asymmetric(
                                    insertion: .push(from: .top).combined(with: .opacity),
                                    removal: .opacity.combined(with: .scale(scale: 0.92))
                                )
                            )
                        }
                    }
                    .animation(.snappy, value: previews.map(\.id))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .top, spacing: 12) {
            StorageHeaderCard(
                storageName: storageName,
                breadcrumb: breadcrumb,
                action: onOpenLocationPicker
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .navigationTitle("Vérifier les objets")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            closeToolbar
            keyboardToolbar
        }
        .confirmationDialog(
            "Fermer sans enregistrer ?",
            isPresented: $showCloseConfirmation,
            titleVisibility: .visible
        ) {
            Button("Fermer", role: .destructive) { onClose() }
        } message: {
            Text("Tous les objets détectés seront perdus.")
        }
    }

    // MARK: - Sub-views

    private var listHeader: some View {
        HStack {
            Text(countLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                onAdd()
            } label: {
                Label("Ajouter", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)
            .accessibilityIdentifier("add-item-button")
        }
        .padding(.horizontal, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            ContentUnavailableView(
                "Aucun objet",
                systemImage: "viewfinder",
                description: Text("Scannez à nouveau ou ajoutez un objet manuellement")
            )
            Button {
                onAdd()
            } label: {
                Label("Ajouter un objet", systemImage: "plus")
                    .font(.body.weight(.semibold))
            }
            .buttonStyle(.glassProminent)
        }
        .padding(.vertical, 32)
    }

    private var bottomBar: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    onScanAnother()
                } label: {
                    Label("Rescanner", systemImage: "camera")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.glass)
                .accessibilityIdentifier("scan-another-button")

                Button {
                    onConfirm()
                } label: {
                    if isConfirming {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    } else {
                        Label("Confirmer", systemImage: "checkmark")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
                .buttonStyle(.glassProminent)
                .disabled(isConfirmDisabled)
                .accessibilityIdentifier("confirm-items-button")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .sensoryFeedback(.success, trigger: isConfirming) { old, new in
            old == false && new == true
        }
    }

    @ToolbarContentBuilder
    private var closeToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Fermer", systemImage: "xmark") {
                showCloseConfirmation = true
            }
            .labelStyle(.iconOnly)
            .accessibilityIdentifier("close-scan-button")
        }
    }

    @ToolbarContentBuilder
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItem(placement: .keyboard) {
            HStack {
                Spacer()
                Button("OK") {
                    focus.wrappedValue = nil
                }
                .font(.body.weight(.semibold))
            }
        }
    }

    // MARK: - Derived

    private var countLabel: String {
        let count = previews.count
        return "\(count) \(count <= 1 ? "objet détecté" : "objets détectés")"
    }

    private var isConfirmDisabled: Bool {
        if isConfirming { return true }
        if previews.isEmpty { return true }
        return previews.contains { $0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private func focusNext(after id: String) {
        guard let index = previews.firstIndex(where: { $0.id == id }) else {
            focus.wrappedValue = nil
            return
        }
        let nextIndex = index + 1
        if nextIndex < previews.count {
            focus.wrappedValue = .name(previews[nextIndex].id)
        } else {
            focus.wrappedValue = nil
        }
    }
}

#Preview("ScanConfirmationPage") {
    @Previewable @State var previews: [EditablePreview] = [
        EditablePreview(id: "1", name: "Perceuse Bosch", category: .tools, description: "", quantity: 1),
        EditablePreview(id: "2", name: "Tournevis cruciforme", category: .tools, description: "", quantity: 3),
    ]
    @Previewable @FocusState var focus: ItemPreviewField?
    return NavigationStack {
        ScanConfirmationPage(
            previews: $previews,
            storageName: "Étagère haute",
            breadcrumb: "Maison · Atelier · Outils",
            isConfirming: false,
            focus: $focus,
            onOpenLocationPicker: {},
            onAdd: {},
            onDuplicate: { _ in },
            onDelete: { id in previews.removeAll { $0.id == id } },
            onScanAnother: {},
            onConfirm: {},
            onClose: {}
        )
    }
}
