import SwiftUI

struct ItemRow: View {
    let name: String
    let category: ItemCategory
    let quantity: Int
    let locationPath: String?
    let addedBy: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .lineLimit(2)
                if let subtitle = buildSubtitle() {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if quantity > 1 {
                Text("×\(quantity)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

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
