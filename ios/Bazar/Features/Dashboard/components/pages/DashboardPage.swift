import SwiftUI

struct DashboardPage: View {
    @Binding var refreshTrigger: Int

    @State private var viewModel = DashboardViewModel()
    @State private var selectedItemId: String?

    var body: some View {
        NavigationStack {
            Group {
                if let data = viewModel.data {
                    List {
                        statsSection(data)

                        if !data.itemsByPlace.isEmpty {
                            Section("Par lieu") {
                                ForEach(data.itemsByPlace) { place in
                                    LabeledInfoRow(
                                        title: place.placeName,
                                        value: "\(place.count)",
                                        icon: "mappin.and.ellipse"
                                    )
                                }
                            }
                        }

                        if !data.itemsByCategory.isEmpty {
                            Section("Par catégorie") {
                                ForEach(data.itemsByCategory) { item in
                                    HStack {
                                        Label(item.category.label, systemImage: item.category.icon)
                                            .foregroundStyle(item.category.color)
                                        Spacer()
                                        Text("\(item.count)")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }

                        if !data.recentItems.isEmpty {
                            Section("Objets récents") {
                                ForEach(data.recentItems) { item in
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
                                }
                            }
                        }
                    }
                } else if let error = viewModel.error {
                    ContentUnavailableView(
                        "Erreur",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else {
                    ProgressView("Chargement...")
                }
            }
            .navigationTitle("Accueil")
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await viewModel.load() }
            .task(id: refreshTrigger) {
                await viewModel.load()
            }
            .sheet(
                item: Binding(
                    get: { selectedItemId.map { ItemIdWrapper(id: $0) } },
                    set: { selectedItemId = $0?.id }
                ),
                onDismiss: { Task { await viewModel.load() } }
            ) { wrapper in
                NavigationStack {
                    ItemDetailPage(itemId: wrapper.id)
                }
            }
        }
    }

    // MARK: - Stats

    @ViewBuilder
    private func statsSection(_ data: DashboardData) -> some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 10) {
            StatCard(
                icon: "archivebox",
                value: "\(data.totalItems)",
                label: "Total",
                color: .blue
            )
            StatCard(
                icon: "tag",
                value: "\(data.itemsByCategory.count)",
                label: "Catégories",
                color: .orange
            )
            StatCard(
                icon: "mappin.and.ellipse",
                value: "\(data.itemsByPlace.count)",
                label: "Lieux",
                color: .green
            )
            StatCard(
                icon: "clock",
                value: "\(data.recentItems.count)",
                label: "Récents",
                color: .purple
            )
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

#Preview {
    DashboardPage(refreshTrigger: .constant(0))
}
