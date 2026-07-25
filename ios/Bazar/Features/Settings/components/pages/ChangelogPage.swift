import SwiftUI

/// The "Nouveautés" list: one section per released version, newest first.
struct ChangelogPage: View {
    let entries: [ChangelogVersion]
    let isLoading: Bool
    let error: String?
    let onRefresh: () async -> Void

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Chargement...")
            } else if let error {
                ContentUnavailableView(
                    "Erreur",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else if entries.isEmpty {
                ContentUnavailableView("Aucune nouveauté", systemImage: "doc.text")
            } else {
                List(entries) { entry in
                    ChangelogEntryRow(version: entry.version, date: entry.date, notes: entry.notes)
                }
            }
        }
        .navigationTitle("Nouveautés")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await onRefresh() }
    }
}

#Preview("Entrées") {
    NavigationStack {
        ChangelogPage(
            entries: [
                ChangelogVersion(
                    version: "1.0.0",
                    date: Date(),
                    notes: [
                        "Scan photo d'une étagère : l'IA nomme et compte chaque objet.",
                        "Une adresse à quatre niveaux pour chaque objet.",
                    ]
                )
            ],
            isLoading: false,
            error: nil,
            onRefresh: {}
        )
    }
}

#Preview("Chargement") {
    NavigationStack {
        ChangelogPage(entries: [], isLoading: true, error: nil, onRefresh: {})
    }
}

#Preview("Erreur") {
    NavigationStack {
        ChangelogPage(entries: [], isLoading: false, error: "Serveur injoignable", onRefresh: {})
    }
}
