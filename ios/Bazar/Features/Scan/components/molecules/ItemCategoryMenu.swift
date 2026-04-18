import SwiftUI

/// Inline row exposing a Menu to pick an ItemCategory.
/// Shows a secondary leading label and the current value with its icon/color.
struct ItemCategoryMenu: View {
    @Binding var category: ItemCategory?

    var body: some View {
        Menu {
            ForEach(ItemCategory.allCases) { option in
                Button {
                    category = option
                } label: {
                    Label(option.label, systemImage: option.icon)
                }
            }

            Divider()

            Button(role: .destructive) {
                category = nil
            } label: {
                Label("Non définie", systemImage: "xmark.circle")
            }
        } label: {
            HStack(spacing: 8) {
                Text("Catégorie")
                    .foregroundStyle(.secondary)

                Spacer()

                if let category {
                    Image(systemName: category.icon)
                        .foregroundStyle(category.color)
                    Text(category.label)
                        .foregroundStyle(.primary)
                } else {
                    Text("Non définie")
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

#Preview("ItemCategoryMenu") {
    @Previewable @State var category: ItemCategory? = .tools
    return VStack(spacing: 16) {
        ItemCategoryMenu(category: $category)
        ItemCategoryMenu(category: .constant(nil))
    }
    .padding()
}
