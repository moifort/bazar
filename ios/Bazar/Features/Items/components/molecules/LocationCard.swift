import SwiftUI

/// Displays the four-level location hierarchy (place → room → zone → storage)
/// as a vertically-stacked breadcrumb. The storage row is emphasized because
/// it is the actual spot where the item lives.
struct LocationCard: View {
    let location: LocationPath?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 12) {
                if let location {
                    levels(for: location)
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
    }

    @ViewBuilder
    private func levels(for location: LocationPath) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            level(icon: "house", name: location.placeName, level: .place)
            level(icon: "door.left.hand.open", name: location.roomName, level: .room)
            level(icon: "rectangle.split.3x1", name: location.zoneName, level: .zone)
            level(icon: "archivebox", name: location.storageName, level: .storage)
        }
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

    @ViewBuilder
    private func level(icon: String, name: String, level: Level) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(level == .storage ? Color.accentColor : .secondary)
                .frame(width: 16)
            Text(name)
                .font(level == .storage ? .body.weight(.semibold) : .subheadline)
                .foregroundStyle(level == .storage ? Color.primary : .secondary)
                .lineLimit(1)
        }
    }

    private enum Level {
        case place
        case room
        case zone
        case storage
    }
}

#Preview("With location") {
    List {
        Section("Lieu") {
            LocationCard(
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
