import SwiftUI

struct ItemDetailPage: View {
    let id: String
    let name: String
    let description: String
    let tags: [String]
    let category: ItemCategory
    let quantity: Int
    let location: LocationPath?
    let personalNotes: String
    let createdAt: Date
    let purchaseDate: Date?
    let purchaseLocation: String
    let purchaseCondition: PurchaseCondition?
    let lowStockThreshold: Int?
    let purchaseLocationSuggestions: [String]
    let reminders: [ReminderRow.Model]

    let onRefresh: () async -> Void
    let onDelete: () async -> Void
    let onEditSave: (ItemEditForm.Fields) async throws -> Void
    let onOpenReminders: () -> Void
    let onOpenMove: () -> Void
    let onOpenPurchaseEdit: () -> Void
    let onOpenLowStockEdit: () -> Void
    let onClose: () -> Void

    @State private var showDeleteConfirmation = false
    @State private var isEditing = false

    var body: some View {
        Group {
            if isEditing {
                ItemEditForm(
                    initial: editFields,
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
            tags: tags,
            purchaseDate: purchaseDate,
            purchaseLocation: purchaseLocation,
            purchaseCondition: purchaseCondition
        )
    }

    @ViewBuilder
    private var itemContent: some View {
        List {
            Section("Informations") {
                LabeledContent("Catégorie") {
                    Label(category.label, systemImage: category.icon)
                        .foregroundStyle(category.color)
                        .labelStyle(.titleAndIcon)
                }
                LabeledContent("Quantité") {
                    HStack(spacing: 6) {
                        if isLowStock {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.callout)
                        }
                        Text("\(quantity)")
                            .foregroundStyle(.secondary)
                    }
                }
                LabeledContent(
                    "Ajouté le",
                    value: createdAt.formatted(date: .abbreviated, time: .omitted)
                )
                Button(action: onOpenMove) {
                    HStack {
                        Text("Lieu")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(location?.fullPath ?? "Non défini")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(2)
                            .truncationMode(.middle)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                            .font(.caption.weight(.semibold))
                    }
                    .contentShape(.rect)
                }
                .accessibilityIdentifier("move-item-row")
                .accessibilityLabel(locationAccessibilityLabel)
                .accessibilityHint("Touchez pour déplacer l'objet")
            }

            // A function that carries nothing has nothing to show: it shrinks to
            // one line in the shared block below. The moment it holds data, it
            // takes its own section back, detail rows and all.
            if hasLowStockAlert {
                Section("Alerte stock") {
                    lowStockRow
                }
            }

            if !reminders.isEmpty {
                Section("Rappels") {
                    ForEach(reminders.prefix(3)) { reminder in
                        ReminderRow(
                            title: reminder.title,
                            notes: reminder.notes,
                            dueDate: reminder.dueDate,
                            isRecurring: reminder.isRecurring,
                            frequencyLabel: reminder.frequencyLabel,
                            isOverdue: reminder.isOverdue,
                            showsOverdueBadge: true
                        )
                    }
                    remindersRow
                }
            }

            if hasPurchaseInfo {
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
                    if let purchaseCondition {
                        LabeledContent("État", value: purchaseCondition.label)
                    }
                    purchaseRow
                }
            }

            if hasPendingActions {
                Section("Actions") {
                    if !hasLowStockAlert { lowStockRow }
                    if reminders.isEmpty { remindersRow }
                    if !hasPurchaseInfo { purchaseRow }
                }
            }

            if !tags.isEmpty {
                Section("Mots-clés") {
                    TagChips(tags: tags)
                        .padding(.vertical, 2)
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

    // The three rows the shared block draws from. Each one reads the same in
    // its own section and in the block — only its wording follows the state.
    private var lowStockRow: some View {
        DetailActionRow(
            title: lowStockSummaryLabel,
            systemImage: lowStockSystemImage,
            action: onOpenLowStockEdit
        )
        .accessibilityIdentifier("edit-low-stock-button")
    }

    private var remindersRow: some View {
        DetailActionRow(
            title: reminders.isEmpty ? "Ajouter un rappel" : "Voir tous les rappels",
            systemImage: "bell.badge",
            badge: reminders.count > 3 ? "\(reminders.count)" : nil,
            action: onOpenReminders
        )
        .accessibilityIdentifier("open-reminders-button")
    }

    private var purchaseRow: some View {
        DetailActionRow(
            title: hasPurchaseInfo ? "Modifier l'achat" : "Ajouter un achat",
            systemImage: "bag.badge.plus",
            action: onOpenPurchaseEdit
        )
        .accessibilityIdentifier("edit-purchase-button")
    }

    private var hasPurchaseInfo: Bool {
        purchaseDate != nil || !purchaseLocation.isEmpty || purchaseCondition != nil
    }

    private var hasLowStockAlert: Bool {
        lowStockThreshold != nil
    }

    private var hasPendingActions: Bool {
        !hasLowStockAlert || reminders.isEmpty || !hasPurchaseInfo
    }

    private var isLowStock: Bool {
        guard let lowStockThreshold else { return false }
        return quantity <= lowStockThreshold
    }

    private var lowStockSummaryLabel: String {
        guard let lowStockThreshold else { return "Configurer une alerte" }
        return "Alerter sous \(lowStockThreshold) en stock"
    }

    private var lowStockSystemImage: String {
        isLowStock ? "exclamationmark.triangle.fill" : "bell.badge.waveform"
    }

    private var locationAccessibilityLabel: String {
        guard let location else { return "Lieu non défini" }
        let storage = location.storageName.map { ", \($0)" } ?? ""
        return "Lieu : \(location.placeName), \(location.roomName), \(location.zoneName)\(storage)"
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
        ToolbarItem(placement: .cancellationAction) {
            Button("Fermer", systemImage: "xmark") {
                onClose()
            }
            .labelStyle(.iconOnly)
            .accessibilityIdentifier("close-item-button")
        }
        ToolbarItem(placement: .primaryAction) {
            Button("Modifier", systemImage: "pencil") {
                isEditing = true
            }
            .labelStyle(.iconOnly)
            .accessibilityIdentifier("edit-item-button")
        }
        ToolbarItem(placement: .secondaryAction) {
            Button("Déplacer", systemImage: "arrow.left.arrow.right") {
                onOpenMove()
            }
            .accessibilityIdentifier("move-item-button")
        }
        ToolbarItem(placement: .secondaryAction) {
            Button("Supprimer", systemImage: "trash", role: .destructive) {
                showDeleteConfirmation = true
            }
            .labelStyle(.iconOnly)
            .accessibilityIdentifier("delete-item-button")
        }
    }
}

/// Row that opens one of the item's satellite editors. Tinted like any list
/// action, with the chevron that says a sheet is behind it.
private struct DetailActionRow: View {
    let title: String
    let systemImage: String
    var badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label(title, systemImage: systemImage)
                Spacer()
                if let badge {
                    Text(badge)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption.weight(.semibold))
            }
            .contentShape(.rect)
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        ItemDetailPage(
            id: "i1",
            name: "Perceuse Bosch",
            description: "Perceuse visseuse sans fil 18V, deux batteries incluses.",
            tags: ["bosch", "18v", "visseuse", "sans fil", "bricolage"],
            category: .tools,
            quantity: 1,
            location: LocationPath(
                fullPath: "Maison > Garage > Établi > Tiroir 1",
                placeId: "p1",
                placeName: "Maison",
                roomId: "r1",
                roomName: "Garage",
                zoneId: "z1",
                zoneName: "Établi",
                storageId: "s1",
                storageName: "Tiroir 1"
            ),
            personalNotes: "Batterie à remplacer bientôt",
            createdAt: Date(timeIntervalSinceNow: -86_400 * 365),
            purchaseDate: Date(timeIntervalSinceNow: -86_400 * 120),
            purchaseLocation: "amazon.fr",
            purchaseCondition: .new,
            lowStockThreshold: nil,
            purchaseLocationSuggestions: ["Amazon", "Leroy Merlin"],
            reminders: [],
            onRefresh: {},
            onDelete: {},
            onEditSave: { _ in },
            onOpenReminders: {},
            onOpenMove: {},
            onOpenPurchaseEdit: {},
            onOpenLowStockEdit: {},
            onClose: {}
        )
    }
}

#Preview("Minimal") {
    NavigationStack {
        ItemDetailPage(
            id: "i2",
            name: "Ampoule LED",
            description: "",
            tags: [],
            category: .electronics,
            quantity: 12,
            location: nil,
            personalNotes: "",
            createdAt: Date(),
            purchaseDate: nil,
            purchaseLocation: "",
            purchaseCondition: nil,
            lowStockThreshold: 5,
            purchaseLocationSuggestions: [],
            reminders: [],
            onRefresh: {},
            onDelete: {},
            onEditSave: { _ in },
            onOpenReminders: {},
            onOpenMove: {},
            onOpenPurchaseEdit: {},
            onOpenLowStockEdit: {},
            onClose: {}
        )
    }
}

/// The three functions configured: nothing is left in the shared block, so it
/// disappears entirely.
#Preview("Tout configuré") {
    NavigationStack {
        ItemDetailPage(
            id: "i3",
            name: "Machine à café",
            description: "",
            tags: ["delonghi", "expresso"],
            category: .appliances,
            quantity: 1,
            location: nil,
            personalNotes: "",
            createdAt: Date(timeIntervalSinceNow: -86_400 * 200),
            purchaseDate: Date(timeIntervalSinceNow: -86_400 * 200),
            purchaseLocation: "Darty",
            purchaseCondition: .new,
            lowStockThreshold: 1,
            purchaseLocationSuggestions: [],
            reminders: [
                .init(
                    id: "r1",
                    title: "Détartrer",
                    notes: "",
                    dueDate: Date(timeIntervalSinceNow: -86_400 * 3),
                    isRecurring: true,
                    frequencyLabel: "Tous les 3 mois",
                    isOverdue: true
                )
            ],
            onRefresh: {},
            onDelete: {},
            onEditSave: { _ in },
            onOpenReminders: {},
            onOpenMove: {},
            onOpenPurchaseEdit: {},
            onOpenLowStockEdit: {},
            onClose: {}
        )
    }
}
