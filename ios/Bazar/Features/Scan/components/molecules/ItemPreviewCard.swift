import SwiftUI

/// Focus identifier used by the confirmation page to route keyboard focus.
enum ItemPreviewField: Hashable {
    case name(String)
}

/// Spacious card used to display and edit a single scanned item preview.
/// Composes the category icon, name text field, category menu and quantity
/// stepper, plus a contextual menu for duplicate/delete actions.
struct ItemPreviewCard: View {
    @Binding var preview: EditablePreview
    var focus: FocusState<ItemPreviewField?>.Binding
    var onSubmit: () -> Void
    var onDuplicate: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .padding(.horizontal, 16)
            ItemCategoryMenu(category: $preview.category)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            Divider()
                .padding(.horizontal, 16)
            QuantityStepper(value: $preview.quantity)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.separator, lineWidth: 0.5)
        )
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            CategoryAvatar(category: preview.category)

            TextField("Nom de l'objet", text: $preview.name, axis: .vertical)
                .font(.title3.weight(.semibold))
                .lineLimit(1...3)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.next)
                .focused(focus, equals: .name(preview.id))
                .onSubmit(onSubmit)
                .accessibilityIdentifier("item-name-field-\(preview.id)")

            Menu {
                Button {
                    onDuplicate()
                } label: {
                    Label("Dupliquer", systemImage: "plus.square.on.square")
                }
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Supprimer", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .contentShape(.rect)
            }
            .accessibilityLabel("Plus d'actions")
            .accessibilityIdentifier("item-more-button-\(preview.id)")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct CategoryAvatar: View {
    let category: ItemCategory?

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.18))
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
        }
        .frame(width: 44, height: 44)
    }

    private var tint: Color {
        category?.color ?? .secondary
    }

    private var icon: String {
        category?.icon ?? "questionmark.folder"
    }
}

#Preview("ItemPreviewCard") {
    @Previewable @FocusState var focus: ItemPreviewField?
    @Previewable @State var preview = EditablePreview(
        id: "1",
        name: "Perceuse Bosch visseuse 18V",
        category: .tools,
        description: "",
        quantity: 3
    )
    return ItemPreviewCard(
        preview: $preview,
        focus: $focus,
        onSubmit: {},
        onDuplicate: {},
        onDelete: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
