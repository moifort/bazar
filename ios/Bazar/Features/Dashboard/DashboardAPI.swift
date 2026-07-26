import Apollo
import Foundation

enum GraphQLDashboardAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func getData() async throws -> DashboardData {
        let query = BazarGraphQL.DashboardQuery()
        let data = try await GraphQLHelpers.fetch(client, query: query)
        let dashboard = data.dashboard
        return DashboardData(
            firstName: data.me?.firstName,
            totalItems: dashboard.totalItems,
            itemsByCategory: dashboard.itemsByCategory.map { entry in
                CategoryCount(
                    category: ItemCategory(rawValue: entry.category.rawValue) ?? .other,
                    count: entry.count
                )
            },
            itemsByPlace: dashboard.itemsByPlace.map { entry in
                PlaceCount(
                    placeId: entry.placeId,
                    placeName: entry.placeName,
                    count: entry.count
                )
            },
            recentItems: dashboard.recentItems.map { item in
                ItemListItem(
                    id: item.id,
                    name: item.name,
                    category: ItemCategory(rawValue: item.category.rawValue) ?? .other,
                    quantity: Int(item.quantity) ?? 1,
                    locationFullPath: item.location?.fullPath,
                    placeId: nil,
                    placeName: nil,
                    roomName: nil,
                    addedBy: item.addedBy,
                    createdAt: GraphQLHelpers.parseISO8601(item.createdAt) ?? Date(),
                    overdueReminderCount: 0
                )
            },
            lowStockItems: dashboard.lowStockItems.compactMap { item in
                guard let threshold = item.lowStockThreshold else { return nil }
                return LowStockAlert(
                    id: item.id,
                    name: item.name,
                    category: ItemCategory(rawValue: item.category.rawValue) ?? .other,
                    quantity: Int(item.quantity) ?? 0,
                    threshold: threshold,
                    locationFullPath: item.location?.fullPath
                )
            }
        )
    }
}
