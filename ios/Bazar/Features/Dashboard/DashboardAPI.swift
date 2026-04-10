import Foundation

enum DashboardAPI {
    static func getData() async throws -> DashboardData {
        DashboardData(
            totalItems: 0,
            itemsByCategory: [],
            itemsByPlace: [],
            recentItems: []
        )
    }
}
