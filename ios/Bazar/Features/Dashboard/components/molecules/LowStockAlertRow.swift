import SwiftUI

struct LowStockAlertRow: View {
    let name: String
    let category: ItemCategory
    let quantity: Int
    let threshold: Int
    let locationPath: String?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if let locationPath, !locationPath.isEmpty {
                    Text(locationPath)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text("\(quantity)/\(threshold)")
                .font(.callout.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(.orange)

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .font(.caption.weight(.semibold))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), stock bas, \(quantity) restants sous le seuil de \(threshold)")
    }
}

#Preview {
    List {
        Section("Alertes stock bas") {
            LowStockAlertRow(
                name: "Boîtes nourriture bébé",
                category: .food,
                quantity: 1,
                threshold: 2,
                locationPath: "Maison > Cuisine > Placard"
            )
            LowStockAlertRow(
                name: "Couches taille 4",
                category: .hygiene,
                quantity: 0,
                threshold: 1,
                locationPath: nil
            )
        }
    }
}
