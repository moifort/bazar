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
    /// Every gallery screen gets a store: the ones that present the Premium sheet
    /// read it from the environment, and an unconfigured one simply sells nothing.
    @State private var subscription = SubscriptionStore()

    var body: some View {
        gallery
            .environment(authSession)
            .environment(subscription)
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
                    quota: Fixtures.freeQuota,
                    onChangelog: {},
                    onUpgrade: {},
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
        case "premium":
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    PremiumSheet(galleryOffers: Fixtures.offers)
                }
        case "quota":
            List {
                QuotaSection(
                    isPremium: false,
                    used: Fixtures.freeQuota.used,
                    limit: Fixtures.freeQuota.limit,
                    renewsOn: Fixtures.freeQuota.renewsOn
                )
                QuotaSection(isPremium: true, used: 214, limit: nil, renewsOn: nil)
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
    static let freeQuota = QuotaState(
        isPremium: false,
        used: 7,
        limit: 10,
        remaining: 3,
        renewsOn: Date(timeIntervalSince1970: 1_785_888_000)
    )

    /// The offers as the App Store would price them in France — frozen so the
    /// sheet renders with no StoreKit behind it.
    static let offers: [PremiumSheet.Offer] = [
        PremiumSheet.Offer(
            id: SubscriptionProducts.yearly,
            title: "Premium — 1 an",
            price: "19,99 €",
            detail: "7 jours d'essai gratuit, puis renouvellement automatique",
            badge: "Économisez 16 %",
            isTrial: true
        ),
        PremiumSheet.Offer(
            id: SubscriptionProducts.monthly,
            title: "Premium — 1 mois",
            price: "1,99 €",
            detail: "sans engagement",
            badge: nil,
            isTrial: false
        ),
    ]

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
