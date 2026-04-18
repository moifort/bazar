import SwiftUI

struct ItemsView: View {
    @Binding var refreshTrigger: Int

    @State private var viewModel = ItemsViewModel()
    @State private var searchViewModel = SearchViewModel()
    @State private var selectedItemId: String?
    @State private var lastViewedItemId: String?
    @State private var itemChanged = false
    @State private var itemDeleted = false

    var body: some View {
        NavigationStack {
            ItemsPage(
                groups: viewModel.groupedItems,
                totalCount: viewModel.totalCount,
                hasMore: viewModel.hasMore,
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.hasItems ? nil : viewModel.error,
                navigationSubtitle: viewModel.navigationSubtitle,
                categoryFilter: $viewModel.categoryFilter,
                searchText: $searchViewModel.searchText,
                isSearching: searchViewModel.isSearching,
                searchResults: searchViewModel.results,
                onRefresh: { await viewModel.load() },
                onLoadMore: { await viewModel.loadMore() },
                onPrefetch: { viewModel.prefetchIfNeeded(for: $0) },
                onItemTap: { selectedItemId = $0 },
                onItemDelete: { id in await deleteItem(id: id) },
                onSearchTextChanged: { searchViewModel.onSearchTextChanged() },
                onSearchSelectItem: { selectedItemId = $0 }
            )
            .task(id: "\(viewModel.filterKey)-\(refreshTrigger)") {
                await viewModel.load()
            }
            .sheet(
                item: Binding(
                    get: { selectedItemId.map { ItemIdWrapper(id: $0) } },
                    set: { selectedItemId = $0?.id }
                ),
                onDismiss: { handleDetailDismiss() }
            ) { wrapper in
                NavigationStack {
                    ItemDetailView(
                        itemId: wrapper.id,
                        onDeleted: { itemDeleted = true },
                        onUpdated: { itemChanged = true }
                    )
                }
                .onAppear { lastViewedItemId = wrapper.id }
            }
        }
    }

    private func handleDetailDismiss() {
        guard let itemId = lastViewedItemId else { return }
        if itemDeleted {
            viewModel.removeItem(id: itemId)
        } else if itemChanged {
            Task { await viewModel.updateItem(id: itemId) }
        }
        itemChanged = false
        itemDeleted = false
        lastViewedItemId = nil
    }

    private func deleteItem(id: String) async {
        do {
            try await GraphQLItemsAPI.delete(id: id)
            viewModel.removeItem(id: id)
        } catch {
            viewModel.error = reportError(error)
        }
    }
}
