#if DEBUG
import SwiftUI

/// Debug-only screen gallery: renders a page with fixture data, without a server
/// or a signed-in user. Launch the app with `-gallery <screen>` (backed by the
/// `gallery` UserDefault) to jump straight to a screen — used to review the design
/// in the simulator and to capture screenshots.
///
///     xcrun simctl launch booted co.polyforms.bazar -gallery settings
struct DebugGallery: View {
    let screen: String
    /// Screens that show the account read the session from the environment; with
    /// nobody signed in they simply show no address.
    @State private var authSession = AuthSession()

    var body: some View {
        gallery.environment(authSession)
    }

    @ViewBuilder
    private var gallery: some View {
        switch screen {
        case "root":
            ContentView()
        case "settings":
            NavigationStack {
                SettingsHomePage(
                    appVersion: "1.0.0",
                    buildNumber: "1",
                    email: "thibaut@example.com",
                    isDeleting: false,
                    onChangelog: {},
                    onSignOut: {},
                    onDeleteAccount: {},
                    onClose: {}
                )
            }
        case "changelog":
            NavigationStack {
                ChangelogPage(
                    entries: Fixtures.changelog,
                    isLoading: false,
                    error: nil,
                    onRefresh: {}
                )
            }
        default:
            ContentUnavailableView(
                "Unknown screen",
                systemImage: "questionmark.square.dashed",
                description: Text(screen)
            )
        }
    }
}

enum Fixtures {
    static let changelog: [ChangelogVersion] = [
        ChangelogVersion(
            version: "1.0.0",
            date: Date(timeIntervalSince1970: 1_785_024_000),
            notes: [
                "Scan photo d'une étagère ou d'un tiroir : l'IA nomme, catégorise et compte chaque objet.",
                "Une adresse à quatre niveaux pour chaque objet — lieu, pièce, zone, rangement.",
                "Recherche dans tout l'inventaire.",
                "Seuil de stock bas par objet, avec une notification dès que la quantité le franchit.",
                "Rappels d'entretien sur n'importe quel objet, ponctuels ou récurrents.",
            ]
        )
    ]
}
#endif
