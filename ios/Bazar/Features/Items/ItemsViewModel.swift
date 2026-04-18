import Foundation

struct ItemPlaceGroup: Identifiable {
    /// `placeId` when the place is known, else the sentinel `"__no_place__"`.
    let id: String
    /// Display label — `placeName`, or `"Sans lieu"` for the orphan bucket.
    let placeName: String
    let items: [ItemListItem]

    static let noPlaceKey = "__no_place__"
    static let noPlaceLabel = "Sans lieu"
}

@MainActor @Observable
final class ItemsViewModel {
    var items: [ItemListItem] = []
    var isLoading = false
    var isLoadingMore = false
    var hasItems = false
    var hasMore = false
    var totalCount = 0
    var error: String?
    var categoryFilter: ItemCategory?
    var placeFilter: (id: String, name: String)?

    private let pageSize = 40
    private let prefetchThreshold = 10

    var filterKey: String {
        let category = categoryFilter?.rawValue ?? "all"
        let place = placeFilter?.id ?? "all"
        return "\(category)-\(place)"
    }

    /// Items bucketed by place, preserving the flat `items` order within each bucket.
    /// Between-section order = first appearance in `items`; the "Sans lieu" group
    /// is always pushed to the end.
    var groupedItems: [ItemPlaceGroup] {
        var buckets: [String: (placeName: String, items: [ItemListItem])] = [:]
        var order: [String] = []
        for item in items {
            let key = item.placeId ?? ItemPlaceGroup.noPlaceKey
            let label = item.placeName ?? ItemPlaceGroup.noPlaceLabel
            if buckets[key] == nil {
                buckets[key] = (label, [])
                order.append(key)
            }
            buckets[key]?.items.append(item)
        }
        let placed = order.filter { $0 != ItemPlaceGroup.noPlaceKey }
        let finalOrder = placed + (order.contains(ItemPlaceGroup.noPlaceKey) ? [ItemPlaceGroup.noPlaceKey] : [])
        return finalOrder.compactMap { key in
            buckets[key].map { ItemPlaceGroup(id: key, placeName: $0.placeName, items: $0.items) }
        }
    }

    var navigationSubtitle: String {
        var parts: [String] = ["\(totalCount) \(totalCount <= 1 ? "objet" : "objets")"]
        if let category = categoryFilter {
            parts.insert(category.label, at: 0)
        }
        if let place = placeFilter {
            parts.insert(place.name, at: 0)
        }
        return parts.joined(separator: " · ")
    }

    func load() async {
        isLoading = true
        error = nil
        do {
            let page = try await fetchPage(offset: 0)
            items = page.items
            totalCount = page.totalCount
            hasMore = page.hasMore
            if !items.isEmpty { hasItems = true }
        } catch is CancellationError {
            // Ignored — task cancelled by SwiftUI (e.g. refreshTrigger changed)
        } catch {
            self.error = reportError(error)
        }
        isLoading = false
    }

    func loadMore() async {
        guard !isLoadingMore && hasMore else { return }
        isLoadingMore = true
        do {
            let page = try await fetchPage(offset: items.count)
            items.append(contentsOf: page.items)
            totalCount = page.totalCount
            hasMore = page.hasMore
        } catch is CancellationError {
            // Ignored
        } catch {
            self.error = reportError(error)
        }
        isLoadingMore = false
    }

    func prefetchIfNeeded(for itemId: String) {
        guard hasMore, !isLoadingMore else { return }
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        if items.count - index <= prefetchThreshold {
            Task { await loadMore() }
        }
    }

    func updateItem(id: String) async {
        do {
            guard let detail = try await GraphQLItemsAPI.getDetail(id: id) else { return }
            guard let index = items.firstIndex(where: { $0.id == id }) else { return }
            let now = Date()
            items[index] = ItemListItem(
                id: detail.id,
                name: detail.name,
                category: detail.category,
                quantity: detail.quantity,
                photoImageId: detail.photoImageId,
                locationFullPath: detail.location?.fullPath,
                placeId: detail.location?.placeId,
                placeName: detail.location?.placeName,
                roomName: detail.location?.roomName,
                addedBy: detail.addedBy,
                createdAt: detail.createdAt,
                overdueReminderCount: detail.reminders.filter { $0.dueDate <= now }.count
            )
        } catch {
            // Silent — worst case the item has stale data until next refresh
        }
    }

    func removeItem(id: String) {
        items.removeAll { $0.id == id }
        totalCount = max(0, totalCount - 1)
    }

    private func fetchPage(offset: Int) async throws -> ItemListPage {
        try await GraphQLItemsAPI.list(
            category: categoryFilter?.rawValue,
            placeId: placeFilter?.id,
            sort: ItemSort.createdAt.rawValue,
            order: "desc",
            offset: offset,
            limit: pageSize
        )
    }
}
