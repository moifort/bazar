import SwiftUI

enum TabSelection: Int, CaseIterable, Identifiable {
    case home, items, scan, locations
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .home: "Accueil"
        case .items: "Objets"
        case .scan: "Scanner"
        case .locations: "Lieux"
        }
    }
    var icon: String {
        switch self {
        case .home: "house"
        case .items: "archivebox"
        case .scan: "camera"
        case .locations: "mappin.and.ellipse"
        }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: TabSelection = .home
    @State private var showScanner = false
    @State private var refreshTrigger = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(TabSelection.home.label, systemImage: TabSelection.home.icon, value: .home) {
                DashboardPage(refreshTrigger: $refreshTrigger)
            }
            Tab(TabSelection.items.label, systemImage: TabSelection.items.icon, value: .items) {
                ItemsPage(refreshTrigger: $refreshTrigger)
            }
            Tab(value: .scan, role: .search) {
                Color.clear
            } label: {
                Label(TabSelection.scan.label, systemImage: TabSelection.scan.icon)
            }
            Tab(TabSelection.locations.label, systemImage: TabSelection.locations.icon, value: .locations) {
                LocationsPage(refreshTrigger: $refreshTrigger)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .scan {
                selectedTab = oldValue
                showScanner = true
            }
        }
        .fullScreenCover(isPresented: $showScanner, onDismiss: { refreshTrigger += 1 }) {
            ScanFlowView {
                showScanner = false
                selectedTab = .items
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshTrigger += 1
            }
        }
    }
}
