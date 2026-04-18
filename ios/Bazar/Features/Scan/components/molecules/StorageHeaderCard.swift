import SwiftUI

/// Glass card shown above the scan confirmation list.
/// Summarises the destination storage (name + breadcrumb) and opens the
/// location picker when tapped.
struct StorageHeaderCard: View {
    let storageName: String?
    let breadcrumb: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                icon

                VStack(alignment: .leading, spacing: 2) {
                    Text(primaryText)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(secondaryText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Modifier le rangement")
    }

    private var icon: some View {
        Image(systemName: storageName == nil ? "mappin.slash" : "archivebox.fill")
            .font(.title3)
            .foregroundStyle(storageName == nil ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.accentColor))
            .frame(width: 40, height: 40)
            .background(.thinMaterial, in: .circle)
    }

    private var primaryText: String {
        storageName ?? "Choisir un emplacement"
    }

    private var secondaryText: String {
        if let breadcrumb, !breadcrumb.isEmpty {
            breadcrumb
        } else if storageName == nil {
            "Toutes les fiches iront au même endroit"
        } else {
            "Appuyez pour modifier"
        }
    }
}

#Preview("Filled") {
    StorageHeaderCard(
        storageName: "Étagère haute",
        breadcrumb: "Maison · Atelier · Outils",
        action: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Empty") {
    StorageHeaderCard(storageName: nil, breadcrumb: nil, action: {})
        .padding()
        .background(Color(.systemGroupedBackground))
}
