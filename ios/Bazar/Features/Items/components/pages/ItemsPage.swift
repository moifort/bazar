import SwiftUI

struct ItemsPage: View {
    @Binding var refreshTrigger: Int

    @State private var viewModel = ItemsViewModel()
    @State private var searchViewModel = SearchViewModel()
    @State private var selectedItemId: String?
    @State private var lastViewedItemId: String?
    @State private var itemChanged = false
    @State private var itemDeleted = false

    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.hasItems && viewModel.isLoading {
                    ProgressView("Chargement...")
                } else if let error = viewModel.error {
                    ContentUnavailableView(
                        "Erreur",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        "Aucun objet",
                        systemImage: "archivebox",
                        description: Text("Scannez des objets pour les ajouter à votre inventaire")
                    )
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            itemButton(item)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task { await deleteItem(id: item.id) }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                        }

                        if viewModel.hasMore {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .listRowSeparator(.hidden)
                                .task { await viewModel.loadMore() }
                        }
                    }
                }
            }
            .navigationTitle("Objets")
            .navigationSubtitle(viewModel.items.isEmpty ? "" : viewModel.navigationSubtitle)
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await viewModel.load() }
            .task(id: "\(viewModel.filterKey)-\(refreshTrigger)") {
                await viewModel.load()
            }
            .toolbar {
                ToolbarItemGroup {
                    Menu {
                        Picker("Catégorie", selection: $viewModel.categoryFilter) {
                            Text("Toutes").tag(nil as ItemCategory?)
                            ForEach(ItemCategory.allCases) { category in
                                Label(category.label, systemImage: category.icon)
                                    .tag(category as ItemCategory?)
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.categoryFilter != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityIdentifier("items-category-filter")
                }
                ToolbarSpacer(.fixed)
                ToolbarItemGroup {
                    Menu {
                        Picker("Tri", selection: $viewModel.sort) {
                            ForEach(ItemSort.allCases) { sort in
                                Label(sort.label, systemImage: sort.icon).tag(sort)
                            }
                        }
                        Toggle(
                            viewModel.sortDescending ? "Décroissant" : "Croissant",
                            isOn: $viewModel.sortDescending
                        )
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    .accessibilityIdentifier("items-sort-menu")
                }
            }
            .searchable(text: $searchViewModel.searchText, prompt: "Chercher un objet, un lieu...")
            .overlay {
                if searchViewModel.isActive {
                    if searchViewModel.isSearching {
                        ProgressView("Recherche...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.regularMaterial)
                    } else if let results = searchViewModel.results {
                        if results.isEmpty {
                            ContentUnavailableView(
                                "Aucun résultat",
                                systemImage: "magnifyingglass",
                                description: Text("Aucun résultat pour « \(searchViewModel.searchText) »")
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.regularMaterial)
                        } else {
                            SearchResultsView(
                                results: results,
                                onSelectItem: { selectedItemId = $0 }
                            )
                        }
                    }
                }
            }
            .onChange(of: searchViewModel.searchText) {
                searchViewModel.onSearchTextChanged()
            }
            .sheet(
                item: Binding(
                    get: { selectedItemId.map { ItemIdWrapper(id: $0) } },
                    set: { selectedItemId = $0?.id }
                ),
                onDismiss: { handleDetailDismiss() }
            ) { wrapper in
                NavigationStack {
                    ItemDetailPage(
                        itemId: wrapper.id,
                        onDeleted: { itemDeleted = true },
                        onUpdated: { itemChanged = true }
                    )
                }
                .onAppear { lastViewedItemId = wrapper.id }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func itemButton(_ item: ItemListItem) -> some View {
        Button {
            selectedItemId = item.id
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
        .onAppear { viewModel.prefetchIfNeeded(for: item.id) }
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

struct ItemIdWrapper: Identifiable {
    let id: String
}

#Preview {
    ItemsPage(refreshTrigger: .constant(0))
}
