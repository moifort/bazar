import SwiftUI

struct ItemRow: View {
    let name: String
    let category: ItemCategory
    let quantity: Int
    let locationPath: String?
    let overdueReminderCount: Int

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(name)
                        .font(.headline)
                        .lineLimit(2)
                    if quantity > 1 {
                        Text("×\(quantity)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.15), in: .capsule)
                    }
                    if overdueReminderCount > 0 {
                        Image(systemName: "bell.badge.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .accessibilityLabel("\(overdueReminderCount) rappel en retard")
                    }
                }
                if let locationPath, !locationPath.isEmpty {
                    Text(locationPath)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            CategoryIcon(icon: category.icon, color: category.color)
        }
        .padding(.vertical, 2)
    }

}

private struct CategoryIcon: View {
    let icon: String
    let color: Color

    var body: some View {
        Image(systemName: icon)
            .font(.callout)
            .foregroundStyle(color)
            .frame(width: 18, height: 18)
            .padding(10)
            .background(color.opacity(0.15), in: .circle)
    }
}

#Preview {
    List {
        ItemRow(
            name: "Perceuse Bosch",
            category: .tools,
            quantity: 1,
            locationPath: "Garage > Établi > Tiroir 1",
            overdueReminderCount: 0
        )
        ItemRow(
            name: "Ampoules LED",
            category: .electronics,
            quantity: 12,
            locationPath: "Cellier",
            overdueReminderCount: 1
        )
        ItemRow(
            name: "Coussin décoratif",
            category: .decor,
            quantity: 1,
            locationPath: nil,
            overdueReminderCount: 0
        )
    }
}
