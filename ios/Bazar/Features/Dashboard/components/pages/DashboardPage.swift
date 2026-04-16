import SwiftUI

struct DashboardPage: View {
    let totalItems: Int
    let placeCounts: [PlaceCountRow]
    let recentItems: [RecentItemRow]
    let onRefresh: () async -> Void
    let onItemTap: (String) -> Void

    var body: some View {
        List {
            if !placeCounts.isEmpty {
                Section("Par lieu") {
                    ForEach(placeCounts) { place in
                        LabeledContent(place.placeName) {
                            Text("\(place.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if !recentItems.isEmpty {
                Section("Récents") {
                    ForEach(recentItems) { item in
                        Button {
                            onItemTap(item.id)
                        } label: {
                            ItemRow(
                                name: item.name,
                                category: item.category,
                                quantity: item.quantity,
                                locationPath: item.locationPath,
                                addedBy: item.addedBy,
                                overdueReminderCount: item.overdueReminderCount
                            )
                        }
                        .tint(.primary)
                    }
                }
            }
        }
        .navigationTitle("Accueil")
        .navigationSubtitle(subtitle)
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await onRefresh() }
        .overlay {
            if placeCounts.isEmpty && recentItems.isEmpty {
                ContentUnavailableView(
                    "Aucun objet",
                    systemImage: "archivebox",
                    description: Text("Scannez vos premiers objets pour les voir apparaître ici")
                )
            }
        }
    }

    private var subtitle: String {
        switch totalItems {
        case 0: ""
        case 1: "1 objet"
        default: "\(totalItems) objets"
        }
    }
}

extension DashboardPage {
    struct PlaceCountRow: Identifiable {
        let id: String
        let placeName: String
        let count: Int
    }

    struct RecentItemRow: Identifiable {
        let id: String
        let name: String
        let category: ItemCategory
        let quantity: Int
        let locationPath: String?
        let addedBy: String
        let overdueReminderCount: Int
    }
}

#Preview("Loaded") {
    NavigationStack {
        DashboardPage(
            totalItems: 152,
            placeCounts: [
                .init(id: "p1", placeName: "Maison", count: 120),
                .init(id: "p2", placeName: "Garage", count: 32),
            ],
            recentItems: [
                .init(id: "i1", name: "Perceuse Bosch", category: .tools, quantity: 1, locationPath: "Maison > Garage", addedBy: "Thibaut", overdueReminderCount: 0),
                .init(id: "i2", name: "Ampoules LED", category: .electronics, quantity: 12, locationPath: "Maison > Cellier", addedBy: "Thibaut", overdueReminderCount: 1),
            ],
            onRefresh: {},
            onItemTap: { _ in }
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        DashboardPage(
            totalItems: 0,
            placeCounts: [],
            recentItems: [],
            onRefresh: {},
            onItemTap: { _ in }
        )
    }
}
