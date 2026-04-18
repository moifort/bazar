import SwiftUI

struct ItemsPage: View {
    let groups: [ItemPlaceGroup]
    let totalCount: Int
    let hasMore: Bool
    let isLoading: Bool
    let errorMessage: String?
    let navigationSubtitle: String

    @Binding var categoryFilter: ItemCategory?
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
            } else if groups.isEmpty && isLoading {
                ProgressView("Chargement...")
            } else if let errorMessage {
                ContentUnavailableView(
                    "Erreur",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if groups.isEmpty {
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
        .navigationSubtitle(groups.isEmpty ? "" : navigationSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await onRefresh() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                filterMenu
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
            ForEach(groups) { group in
                Section(group.placeName) {
                    ForEach(group.items) { item in
                        itemButton(item)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { await onItemDelete(item.id) }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
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

    private var filterMenu: some View {
        Menu {
            Picker("Catégorie", selection: $categoryFilter) {
                Text("Toutes les catégories").tag(nil as ItemCategory?)
                ForEach(ItemCategory.allCases) { category in
                    Label(category.label, systemImage: category.icon)
                        .tag(category as ItemCategory?)
                }
            }
        } label: {
            Image(systemName: categoryFilter != nil
                ? "line.3.horizontal.decrease.circle.fill"
                : "line.3.horizontal.decrease.circle")
        }
        .accessibilityIdentifier("items-filter-menu")
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
                locationPath: item.shortLocationPath,
                overdueReminderCount: item.overdueReminderCount
            )
        }
        .tint(.primary)
        .onAppear { onPrefetch(item.id) }
    }
}

#Preview("Loaded") {
    @Previewable @State var categoryFilter: ItemCategory?
    @Previewable @State var searchText = ""

    NavigationStack {
        ItemsPage(
            groups: [
                ItemPlaceGroup(
                    id: "p1",
                    placeName: "Maison",
                    items: [
                        ItemListItem(id: "1", name: "Perceuse Bosch", category: .tools, quantity: 1, photoImageId: nil, locationFullPath: "Maison > Garage", placeId: "p1", placeName: "Maison", roomName: "Garage", addedBy: "Thibaut", createdAt: .now, overdueReminderCount: 0),
                        ItemListItem(id: "2", name: "Ampoules LED", category: .electronics, quantity: 12, photoImageId: nil, locationFullPath: "Maison > Cellier", placeId: "p1", placeName: "Maison", roomName: "Cellier", addedBy: "Thibaut", createdAt: .now, overdueReminderCount: 0),
                    ]
                ),
            ],
            totalCount: 2,
            hasMore: false,
            isLoading: false,
            errorMessage: nil,
            navigationSubtitle: "2 objets",
            categoryFilter: $categoryFilter,
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
    @Previewable @State var searchText = ""

    NavigationStack {
        ItemsPage(
            groups: [],
            totalCount: 0,
            hasMore: false,
            isLoading: false,
            errorMessage: nil,
            navigationSubtitle: "",
            categoryFilter: $categoryFilter,
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
    @Previewable @State var searchText = "perceuse"

    NavigationStack {
        ItemsPage(
            groups: [
                ItemPlaceGroup(
                    id: "p1",
                    placeName: "Maison",
                    items: [
                        ItemListItem(id: "1", name: "Perceuse Bosch", category: .tools, quantity: 1, photoImageId: nil, locationFullPath: "Maison > Garage", placeId: "p1", placeName: "Maison", roomName: "Garage", addedBy: "Thibaut", createdAt: .now, overdueReminderCount: 0),
                    ]
                ),
            ],
            totalCount: 1,
            hasMore: false,
            isLoading: false,
            errorMessage: nil,
            navigationSubtitle: "1 objet",
            categoryFilter: $categoryFilter,
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

#Preview("Multiple places") {
    @Previewable @State var categoryFilter: ItemCategory?
    @Previewable @State var searchText = ""

    NavigationStack {
        ItemsPage(
            groups: [
                ItemPlaceGroup(
                    id: "p1",
                    placeName: "Appartement",
                    items: [
                        ItemListItem(id: "1", name: "Perceuse Bosch", category: .tools, quantity: 1, photoImageId: nil, locationFullPath: "Appartement > Cuisine > Placard > Étagère 2", placeId: "p1", placeName: "Appartement", roomName: "Cuisine", addedBy: "Thibaut", createdAt: .now, overdueReminderCount: 0),
                        ItemListItem(id: "2", name: "Ampoules LED", category: .electronics, quantity: 12, photoImageId: nil, locationFullPath: "Appartement > Salon", placeId: "p1", placeName: "Appartement", roomName: "Salon", addedBy: "Thibaut", createdAt: .now, overdueReminderCount: 0),
                    ]
                ),
                ItemPlaceGroup(
                    id: "p2",
                    placeName: "Cave",
                    items: [
                        ItemListItem(id: "3", name: "Ski de fond", category: .sports, quantity: 1, photoImageId: nil, locationFullPath: "Cave > Entrepôt > Étagère A", placeId: "p2", placeName: "Cave", roomName: "Entrepôt", addedBy: "Thibaut", createdAt: .now, overdueReminderCount: 0),
                    ]
                ),
            ],
            totalCount: 3,
            hasMore: false,
            isLoading: false,
            errorMessage: nil,
            navigationSubtitle: "3 objets",
            categoryFilter: $categoryFilter,
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
