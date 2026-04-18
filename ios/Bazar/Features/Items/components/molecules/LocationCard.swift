import SwiftUI

/// Displays the four-level location hierarchy (place → room → zone → storage)
/// as a compact two-line Apple-style breadcrumb:
/// - Line 1: `Place › Room`  (primary, emphasized)
/// - Line 2: `Zone › Storage` (secondary, supporting path)
struct LocationCard: View {
    let location: LocationPath?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                if let location {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.body)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(location.placeName) › \(location.roomName)")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Text("\(location.zoneName) › \(location.storageName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .accessibilityElement(children: .combine)
                } else {
                    emptyState
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.caption.weight(.semibold))
            }
            .contentShape(.rect)
        }
        .tint(.primary)
        .accessibilityIdentifier("move-item-row")
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Touchez pour déplacer l'objet")
    }

    private var accessibilityLabel: String {
        guard let location else { return "Lieu non défini" }
        return "Lieu : \(location.placeName), \(location.roomName), \(location.zoneName), \(location.storageName)"
    }

    @ViewBuilder
    private var emptyState: some View {
        HStack(spacing: 8) {
            Image(systemName: "mappin.slash")
                .foregroundStyle(.secondary)
            Text("Lieu non défini")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("With location") {
    List {
        Section("Lieu") {
            LocationCard(
                location: LocationPath(
                    fullPath: "Maison > Salon > Étagère > Boîte 3",
                    placeId: "p1",
                    placeName: "Maison",
                    roomId: "r1",
                    roomName: "Salon",
                    zoneId: "z1",
                    zoneName: "Étagère",
                    storageId: "s1",
                    storageName: "Boîte 3"
                ),
                onTap: {}
            )
        }
    }
}

#Preview("Empty") {
    List {
        Section("Lieu") {
            LocationCard(location: nil, onTap: {})
        }
    }
}

#Preview("Long names") {
    List {
        Section("Lieu") {
            LocationCard(
                location: LocationPath(
                    fullPath: "Résidence secondaire > Chambre d'amis du rez-de-chaussée > Armoire Louis XV > Tiroir du milieu à gauche",
                    placeId: "p1",
                    placeName: "Résidence secondaire",
                    roomId: "r1",
                    roomName: "Chambre d'amis du rez-de-chaussée",
                    zoneId: "z1",
                    zoneName: "Armoire Louis XV",
                    storageId: "s1",
                    storageName: "Tiroir du milieu à gauche"
                ),
                onTap: {}
            )
        }
    }
}
