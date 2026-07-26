import SwiftUI

struct DashboardView: View {
    @Binding var refreshTrigger: Int

    @State private var viewModel = DashboardViewModel()
    @State private var selectedItemId: String?
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if let data = viewModel.data {
                    DashboardPage(
                        firstName: data.firstName,
                        totalItems: data.totalItems,
                        placeCounts: data.itemsByPlace.map { entry in
                            .init(id: entry.placeId, placeName: entry.placeName, count: entry.count)
                        },
                        recentItems: data.recentItems.map { item in
                            .init(
                                id: item.id,
                                name: item.name,
                                category: item.category,
                                quantity: item.quantity,
                                locationPath: item.locationFullPath,
                                overdueReminderCount: item.overdueReminderCount
                            )
                        },
                        lowStockAlerts: data.lowStockItems.map { alert in
                            .init(
                                id: alert.id,
                                name: alert.name,
                                category: alert.category,
                                quantity: alert.quantity,
                                threshold: alert.threshold,
                                locationPath: alert.locationFullPath
                            )
                        },
                        onRefresh: { await viewModel.load() },
                        onItemTap: { selectedItemId = $0 },
                        onSettings: { showSettings = true }
                    )
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
                    ItemDetailView(itemId: wrapper.id)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}
