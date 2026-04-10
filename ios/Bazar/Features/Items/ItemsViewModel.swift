import Foundation

@MainActor @Observable
final class ItemsViewModel {
    var items: [ItemListItem] = []
    var isLoading = false
    var isLoadingMore = false
    var hasItems = false
    var hasMore = false
    var totalCount = 0
    var error: String?
    var sort: ItemSort = .createdAt
    var sortDescending = true
    var categoryFilter: ItemCategory?
    var placeFilter: (id: String, name: String)?

    private let pageSize = 40
    private let prefetchThreshold = 10

    var filterKey: String {
        let category = categoryFilter?.rawValue ?? "all"
        let place = placeFilter?.id ?? "all"
        return "\(sort.rawValue)-\(sortDescending)-\(category)-\(place)"
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
            guard let detail = try await ItemsAPI.getDetail(id: id) else { return }
            guard let index = items.firstIndex(where: { $0.id == id }) else { return }
            items[index] = ItemListItem(
                id: detail.id,
                name: detail.name,
                category: detail.category,
                quantity: detail.quantity,
                photoImageId: detail.photoImageId,
                locationFullPath: detail.location?.fullPath,
                addedBy: detail.addedBy,
                createdAt: detail.createdAt
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
        try await ItemsAPI.list(
            category: categoryFilter?.rawValue,
            placeId: placeFilter?.id,
            sort: sort.rawValue,
            order: sortDescending ? "desc" : "asc",
            offset: offset,
            limit: pageSize
        )
    }
}
