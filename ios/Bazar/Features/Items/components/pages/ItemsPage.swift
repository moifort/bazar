import SwiftUI

struct ItemsPage: View {
    let items: [ItemListItem]
    let totalCount: Int
    let hasMore: Bool
    let isLoading: Bool
    let errorMessage: String?
    let navigationSubtitle: String

    @Binding var categoryFilter: ItemCategory?
    @Binding var sort: ItemSort
    @Binding var sortDescending: Bool
    @Binding var searchText: String

    let isSearching: Bool
    let searchResults: [SearchEntry]?

    let onRefresh: () async -> Void
    let onLoadMore: () async -> Void
    let onPrefetch: (String) -> Void
    let onItemTap: (String) -> Void
    let onItemDelete: (String) async -> Void
    let onSearchTextChanged: () -> Void
    let onSearchSelectItem: (String) -> Void

    var body: some View {
        Group {
            if !searchText.isEmpty {
                searchContent
            } else if items.isEmpty && isLoading {
                ProgressView("Chargement...")
            } else if let errorMessage {
                ContentUnavailableView(
                    "Erreur",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if items.isEmpty {
                ContentUnavailableView(
                    "Aucun objet",
                    systemImage: "archivebox",
                    description: Text("Scannez des objets pour les ajouter à votre inventaire")
                )
            } else {
                itemsList
            }
        }
        .navigationTitle("Objets")
        .navigationSubtitle(items.isEmpty ? "" : navigationSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await onRefresh() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                filterAndSortMenu
            }
        }
        .searchable(text: $searchText, prompt: "Chercher un objet, un lieu...")
        .onChange(of: searchText) {
            onSearchTextChanged()
        }
    }

    @ViewBuilder
    private var itemsList: some View {
        List {
            ForEach(items) { item in
                itemButton(item)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await onItemDelete(item.id) }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }

            if hasMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .task { await onLoadMore() }
            }
        }
    }

    @ViewBuilder
    private var searchContent: some View {
        if isSearching && searchResults == nil {
            ProgressView("Recherche...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let searchResults, searchResults.isEmpty {
            ContentUnavailableView(
                "Aucun résultat",
                systemImage: "magnifyingglass",
                description: Text("Aucun résultat pour « \(searchText) »")
            )
        } else if let searchResults {
            SearchResultsView(
                results: searchResults,
                onSelectItem: onSearchSelectItem
            )
        }
    }

    private var filterAndSortMenu: some View {
        Menu {
            Section("Filtrer") {
                Picker("Catégorie", selection: $categoryFilter) {
                    Text("Toutes les catégories").tag(nil as ItemCategory?)
                    ForEach(ItemCategory.allCases) { category in
                        Label(category.label, systemImage: category.icon)
                            .tag(category as ItemCategory?)
                    }
                }
            }
            Section("Trier") {
                Picker("Trier par", selection: $sort) {
                    ForEach(ItemSort.allCases) { sortOption in
                        Label(sortOption.label, systemImage: sortOption.icon).tag(sortOption)
                    }
                }
                Toggle(sortDescending ? "Décroissant" : "Croissant", isOn: $sortDescending)
            }
        } label: {
            Image(systemName: categoryFilter != nil
                ? "line.3.horizontal.decrease.circle.fill"
                : "line.3.horizontal.decrease.circle")
        }
        .accessibilityIdentifier("items-filter-sort-menu")
    }

    @ViewBuilder
    private func itemButton(_ item: ItemListItem) -> some View {
        Button {
            onItemTap(item.id)
        } label: {
            ItemRow(
                name: item.name,
                category: item.category,
                quantity: item.quantity,
                locationPath: item.locationFullPath,
                addedBy: item.addedBy,
                overdueReminderCount: item.overdueReminderCount
            )
        }
        .tint(.primary)
        .onAppear { onPrefetch(item.id) }
    }
}

#Preview("Loaded") {
    @Previewable @State var categoryFilter: ItemCategory?
    @Previewable @State var sort: ItemSort = .createdAt
    @Previewable @State var sortDescending = true
    @Previewable @State var searchText = ""

    NavigationStack {
        ItemsPage(
            items: [
                ItemListItem(id: "1", name: "Perceuse Bosch", category: .tools, quantity: 1, photoImageId: nil, locationFullPath: "Maison > Garage", addedBy: "Thibaut", createdAt: .now, overdueReminderCount: 0),
                ItemListItem(id: "2", name: "Ampoules LED", category: .electronics, quantity: 12, photoImageId: nil, locationFullPath: "Maison > Cellier", addedBy: "Thibaut", createdAt: .now, overdueReminderCount: 0),
            ],
            totalCount: 2,
            hasMore: false,
            isLoading: false,
            errorMessage: nil,
            navigationSubtitle: "2 objets",
            categoryFilter: $categoryFilter,
            sort: $sort,
            sortDescending: $sortDescending,
            searchText: $searchText,
            isSearching: false,
            searchResults: nil,
            onRefresh: {},
            onLoadMore: {},
            onPrefetch: { _ in },
            onItemTap: { _ in },
            onItemDelete: { _ in },
            onSearchTextChanged: {},
            onSearchSelectItem: { _ in }
        )
    }
}

#Preview("Empty") {
    @Previewable @State var categoryFilter: ItemCategory?
    @Previewable @State var sort: ItemSort = .createdAt
    @Previewable @State var sortDescending = true
    @Previewable @State var searchText = ""

    NavigationStack {
        ItemsPage(
            items: [],
            totalCount: 0,
            hasMore: false,
            isLoading: false,
            errorMessage: nil,
            navigationSubtitle: "",
            categoryFilter: $categoryFilter,
            sort: $sort,
            sortDescending: $sortDescending,
            searchText: $searchText,
            isSearching: false,
            searchResults: nil,
            onRefresh: {},
            onLoadMore: {},
            onPrefetch: { _ in },
            onItemTap: { _ in },
            onItemDelete: { _ in },
            onSearchTextChanged: {},
            onSearchSelectItem: { _ in }
        )
    }
}

#Preview("Searching") {
    @Previewable @State var categoryFilter: ItemCategory?
    @Previewable @State var sort: ItemSort = .createdAt
    @Previewable @State var sortDescending = true
    @Previewable @State var searchText = "perceuse"

    NavigationStack {
        ItemsPage(
            items: [
                ItemListItem(id: "1", name: "Perceuse Bosch", category: .tools, quantity: 1, photoImageId: nil, locationFullPath: "Maison > Garage", addedBy: "Thibaut", createdAt: .now, overdueReminderCount: 0),
            ],
            totalCount: 1,
            hasMore: false,
            isLoading: false,
            errorMessage: nil,
            navigationSubtitle: "1 objet",
            categoryFilter: $categoryFilter,
            sort: $sort,
            sortDescending: $sortDescending,
            searchText: $searchText,
            isSearching: false,
            searchResults: [
                SearchEntry(type: "item", entityId: "1", text: "Perceuse Bosch"),
            ],
            onRefresh: {},
            onLoadMore: {},
            onPrefetch: { _ in },
            onItemTap: { _ in },
            onItemDelete: { _ in },
            onSearchTextChanged: {},
            onSearchSelectItem: { _ in }
        )
    }
}
