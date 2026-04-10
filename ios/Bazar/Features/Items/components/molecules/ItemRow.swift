import SwiftUI

struct ItemRow: View {
    let name: String
    let category: ItemCategory
    let quantity: Int
    let locationPath: String?
    let addedBy: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: category.icon)
                .font(.caption)
                .foregroundStyle(category.color)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(.headline)
                        .lineLimit(2)
                    if quantity > 1 {
                        Text("×\(quantity)")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .foregroundStyle(.white)
                            .background(category.color, in: .capsule)
                    }
                }
                if let subtitle = buildSubtitle() {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            CategoryBadge(label: category.label, icon: category.icon, color: category.color)
        }
        .padding(.vertical, 2)
    }

    private func buildSubtitle() -> String? {
        let parts: [String?] = [locationPath, addedBy]
        let filtered = parts.compactMap { $0 }.filter { !$0.isEmpty }
        return filtered.isEmpty ? nil : filtered.joined(separator: " · ")
    }
}

#Preview {
    List {
        ItemRow(
            name: "Perceuse Bosch",
            category: .tools,
            quantity: 1,
            locationPath: "Maison > Garage > Établi > Tiroir 1",
            addedBy: "Thibaut"
        )
        ItemRow(
            name: "Ampoules LED",
            category: .electronics,
            quantity: 12,
            locationPath: "Maison > Cellier",
            addedBy: "Thibaut"
        )
        ItemRow(
            name: "Coussin décoratif",
            category: .decor,
            quantity: 1,
            locationPath: nil,
            addedBy: "Alice"
        )
    }
}
