import SwiftUI

struct DashboardPage: View {
    let totalItems: Int
    let categoryCounts: [CategoryCountRow]
    let placeCounts: [PlaceCountRow]
    let recentItems: [RecentItemRow]
    let onRefresh: () async -> Void
    let onItemTap: (String) -> Void

    var body: some View {
        List {
            statsSection

            if !placeCounts.isEmpty {
                Section("Par lieu") {
                    ForEach(placeCounts) { place in
                        LabeledInfoRow(
                            title: place.placeName,
                            value: "\(place.count)",
                            icon: "mappin.and.ellipse"
                        )
                    }
                }
            }

            if !categoryCounts.isEmpty {
                Section("Par catégorie") {
                    ForEach(categoryCounts) { entry in
                        HStack {
                            Label(entry.category.label, systemImage: entry.category.icon)
                                .foregroundStyle(entry.category.color)
                            Spacer()
                            Text("\(entry.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if !recentItems.isEmpty {
                Section("Objets récents") {
                    ForEach(recentItems) { item in
                        Button {
                            onItemTap(item.id)
                        } label: {
                            ItemRow(
                                name: item.name,
                                category: item.category,
                                quantity: item.quantity,
                                locationPath: item.locationPath,
                                addedBy: item.addedBy
                            )
                        }
                        .tint(.primary)
                    }
                }
            }
        }
        .navigationTitle("Accueil")
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await onRefresh() }
    }

    @ViewBuilder
    private var statsSection: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 10) {
            StatCard(
                icon: "archivebox",
                value: "\(totalItems)",
                label: "Total",
                color: .blue
            )
            StatCard(
                icon: "tag",
                value: "\(categoryCounts.count)",
                label: "Catégories",
                color: .orange
            )
            StatCard(
                icon: "mappin.and.ellipse",
                value: "\(placeCounts.count)",
                label: "Lieux",
                color: .green
            )
            StatCard(
                icon: "clock",
                value: "\(recentItems.count)",
                label: "Récents",
                color: .purple
            )
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

extension DashboardPage {
    struct CategoryCountRow: Identifiable {
        let category: ItemCategory
        let count: Int
        var id: String { category.rawValue }
    }

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
    }
}

#Preview("Loaded") {
    NavigationStack {
        DashboardPage(
            totalItems: 152,
            categoryCounts: [
                .init(category: .tools, count: 24),
                .init(category: .electronics, count: 18),
                .init(category: .books, count: 42),
            ],
            placeCounts: [
                .init(id: "p1", placeName: "Maison", count: 120),
                .init(id: "p2", placeName: "Garage", count: 32),
            ],
            recentItems: [
                .init(id: "i1", name: "Perceuse Bosch", category: .tools, quantity: 1, locationPath: "Maison > Garage", addedBy: "Thibaut"),
                .init(id: "i2", name: "Ampoules LED", category: .electronics, quantity: 12, locationPath: "Maison > Cellier", addedBy: "Thibaut"),
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
            categoryCounts: [],
            placeCounts: [],
            recentItems: [],
            onRefresh: {},
            onItemTap: { _ in }
        )
    }
}

#Preview("Refreshing (pull to refresh)") {
    NavigationStack {
        DashboardPage(
            totalItems: 42,
            categoryCounts: [.init(category: .tools, count: 10)],
            placeCounts: [.init(id: "p1", placeName: "Maison", count: 42)],
            recentItems: [],
            onRefresh: { try? await Task.sleep(for: .seconds(2)) },
            onItemTap: { _ in }
        )
    }
}
