import SwiftUI

struct SearchResultsView: View {
    let results: [SearchEntry]
    let onSelectItem: (String) -> Void

    private var itemResults: [SearchEntry] {
        results.filter { $0.type == "item" }
    }

    private var locationResults: [SearchEntry] {
        results.filter { $0.type == "location" }
    }

    var body: some View {
        List {
            if !itemResults.isEmpty {
                Section("Objets") {
                    ForEach(itemResults) { entry in
                        Button {
                            onSelectItem(entry.entityId)
                        } label: {
                            Label(entry.text, systemImage: "archivebox")
                        }
                        .tint(.primary)
                    }
                }
            }

            if !locationResults.isEmpty {
                Section("Lieux") {
                    ForEach(locationResults) { entry in
                        Label(entry.text, systemImage: "mappin.and.ellipse")
                    }
                }
            }
        }
    }
}

#Preview {
    SearchResultsView(
        results: [
            SearchEntry(type: "item", entityId: "1", text: "Perceuse Bosch"),
            SearchEntry(type: "item", entityId: "2", text: "Tournevis cruciforme"),
            SearchEntry(type: "location", entityId: "3", text: "Garage > Établi"),
        ],
        onSelectItem: { _ in }
    )
}
