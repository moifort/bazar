import Foundation

enum ItemsAPI {
    static func list(
        category: String?,
        placeId: String?,
        sort: String?,
        order: String?,
        offset: Int?,
        limit: Int?
    ) async throws -> ItemListPage {
        ItemListPage(items: [], totalCount: 0, hasMore: false)
    }

    static func getDetail(id: String) async throws -> Item? {
        nil
    }

    static func delete(id: String) async throws {}

    static func move(id: String, storageId: String) async throws -> Item? {
        nil
    }
}
