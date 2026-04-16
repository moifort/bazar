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
            if items.isEmpty && isLoading {
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
        }
        .navigationTitle("Objets")
        .navigationSubtitle(items.isEmpty ? "" : navigationSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await onRefresh() }
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    Picker("Catégorie", selection: $categoryFilter) {
                        Text("Toutes").tag(nil as ItemCategory?)
                        ForEach(ItemCategory.allCases) { category in
                            Label(category.label, systemImage: category.icon)
                                .tag(category as ItemCategory?)
                        }
                    }
                } label: {
                    Image(systemName: categoryFilter != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                }
                .accessibilityIdentifier("items-category-filter")
            }
            ToolbarSpacer(.fixed)
            ToolbarItemGroup {
                Menu {
                    Picker("Tri", selection: $sort) {
                        ForEach(ItemSort.allCases) { sortOption in
                            Label(sortOption.label, systemImage: sortOption.icon).tag(sortOption)
                        }
                    }
                    Toggle(
                        sortDescending ? "Décroissant" : "Croissant",
                        isOn: $sortDescending
                    )
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
                .accessibilityIdentifier("items-sort-menu")
            }
        }
        .searchable(text: $searchText, prompt: "Chercher un objet, un lieu...")
        .overlay {
            if !searchText.isEmpty {
                if isSearching {
                    ProgressView("Recherche...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.regularMaterial)
                } else if let searchResults {
                    if searchResults.isEmpty {
                        ContentUnavailableView(
                            "Aucun résultat",
                            systemImage: "magnifyingglass",
                            description: Text("Aucun résultat pour « \(searchText) »")
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.regularMaterial)
                    } else {
                        SearchResultsView(
                            results: searchResults,
                            onSelectItem: onSearchSelectItem
                        )
                    }
                }
            }
        }
        .onChange(of: searchText) {
            onSearchTextChanged()
        }
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
                addedBy: item.addedBy
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
                ItemListItem(id: "1", name: "Perceuse Bosch", category: .tools, quantity: 1, photoImageId: nil, locationFullPath: "Maison > Garage", addedBy: "Thibaut", createdAt: .now),
                ItemListItem(id: "2", name: "Ampoules LED", category: .electronics, quantity: 12, photoImageId: nil, locationFullPath: "Maison > Cellier", addedBy: "Thibaut", createdAt: .now),
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
                ItemListItem(id: "1", name: "Perceuse Bosch", category: .tools, quantity: 1, photoImageId: nil, locationFullPath: "Maison > Garage", addedBy: "Thibaut", createdAt: .now),
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
