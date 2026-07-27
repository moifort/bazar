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
        case "dashboard":
            NavigationStack {
                DashboardPage(
                    firstName: "Thibaut",
                    totalItems: 152,
                    placeCounts: Fixtures.placeCounts,
                    recentItems: Fixtures.recentItems,
                    lowStockAlerts: Fixtures.lowStockAlerts,
                    onRefresh: {},
                    onItemTap: { _ in },
                    onSettings: {}
                )
            }
        case "items":
            NavigationStack {
                ItemsPage(
                    groups: Fixtures.itemGroups,
                    totalCount: 152,
                    hasMore: true,
                    isLoading: false,
                    errorMessage: nil,
                    navigationSubtitle: "152 objets",
                    categoryFilter: .constant(nil),
                    searchText: .constant(""),
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
        case "item-detail":
            NavigationStack {
                ItemDetailPage(
                    id: "i1",
                    name: "Pot d'épices",
                    description: "Pots de 50 g étiquetés, rangés sur le porte-épices.",
                    tags: ["cumin", "paprika", "curry", "épice", "condiment", "cuisine"],
                    category: .food,
                    quantity: 12,
                    location: Fixtures.itemLocation,
                    personalNotes: "",
                    createdAt: Date(timeIntervalSinceNow: -86_400 * 30),
                    purchaseDate: nil,
                    purchaseLocation: "",
                    purchaseCondition: nil,
                    lowStockThreshold: 3,
                    purchaseLocationSuggestions: [],
                    reminders: [],
                    onRefresh: {},
                    onDelete: {},
                    onEditSave: { _ in },
                    onOpenReminders: {},
                    onOpenMove: {},
                    onOpenPurchaseEdit: {},
                    onOpenLowStockEdit: {},
                    onClose: {}
                )
            }
        case "item-detail-full":
            NavigationStack {
                ItemDetailPage(
                    id: "i2",
                    name: "Machine à café",
                    description: "",
                    tags: ["delonghi", "expresso", "cafetière"],
                    category: .appliances,
                    quantity: 1,
                    location: Fixtures.itemLocation,
                    personalNotes: "",
                    createdAt: Date(timeIntervalSinceNow: -86_400 * 200),
                    purchaseDate: Date(timeIntervalSinceNow: -86_400 * 200),
                    purchaseLocation: "Darty",
                    purchaseCondition: .new,
                    lowStockThreshold: 1,
                    purchaseLocationSuggestions: [],
                    reminders: Fixtures.itemReminders,
                    onRefresh: {},
                    onDelete: {},
                    onEditSave: { _ in },
                    onOpenReminders: {},
                    onOpenMove: {},
                    onOpenPurchaseEdit: {},
                    onOpenLowStockEdit: {},
                    onClose: {}
                )
            }
        case "locations":
            NavigationStack {
                LocationsPage(
                    places: Fixtures.places,
                    isLoading: false,
                    errorMessage: nil,
                    onRefresh: {},
                    onAddPlace: { _ in },
                    onDeletePlace: { _ in },
                    onEditPlace: { _, _, _ in },
                    onReorderPlaces: { _, _ in }
                )
            }
        case "onboarding-name":
            OnboardingGalleryPage(step: .name)
        case "onboarding-house":
            OnboardingGalleryPage(step: .house)
        case "onboarding-rooms":
            OnboardingGalleryPage(step: .rooms)
        case "scan-preview":
            ScanFlowPage(
                step: .preview(Fixtures.previews),
                errorMessage: nil,
                selectedPhoto: .constant(nil),
                onCapture: { _ in },
                onScanAnother: {},
                onConfirm: { _, _ in },
                onDismiss: {},
                onErrorDismiss: {}
            )
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

/// The onboarding page holds what the user types, so the gallery needs somewhere
/// to hold it too — a page rendered with constant bindings would not react to a
/// keystroke.
private struct OnboardingGalleryPage: View {
    let step: OnboardingPage.Step

    @State private var firstName = ""
    @State private var houseName = ""
    @State private var selectedRooms = SuggestedRooms.preselected

    var body: some View {
        OnboardingPage(
            step: step,
            firstName: $firstName,
            houseName: $houseName,
            selectedRooms: $selectedRooms,
            suggestedRooms: SuggestedRooms.all,
            continueLabel: step == .rooms ? "Terminer" : "Continuer",
            canContinue: true,
            isSubmitting: false,
            errorMessage: nil,
            onContinue: {},
            onBack: step == .name ? nil : {}
        )
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

    static let placeCounts: [DashboardPage.PlaceCountRow] = [
        .init(id: "p1", placeName: "Appartement", count: 118),
        .init(id: "p2", placeName: "Cave", count: 34),
    ]

    static let recentItems: [DashboardPage.RecentItemRow] = [
        .init(id: "i1", name: "Perceuse Bosch", category: .tools, quantity: 1, locationPath: "Appartement > Garage > Établi", overdueReminderCount: 0),
        .init(id: "i2", name: "Ampoules LED E27", category: .electronics, quantity: 12, locationPath: "Appartement > Cellier > Étagère 2", overdueReminderCount: 0),
        .init(id: "i3", name: "Machine à café", category: .appliances, quantity: 1, locationPath: "Appartement > Cuisine > Plan de travail", overdueReminderCount: 1),
    ]

    static let lowStockAlerts: [LowStockAlertRow.Model] = [
        .init(id: "i4", name: "Café en grains", category: .food, quantity: 1, threshold: 2, locationPath: "Appartement > Cuisine > Placard haut"),
        .init(id: "i5", name: "Piles AA", category: .electronics, quantity: 2, threshold: 4, locationPath: "Appartement > Bureau > Tiroir 1"),
    ]

    static let itemGroups: [ItemPlaceGroup] = [
        ItemPlaceGroup(
            id: "p1",
            placeName: "Appartement",
            items: [
                item("i1", "Perceuse Bosch", .tools, 1, "Appartement > Garage > Établi"),
                item("i2", "Ampoules LED E27", .electronics, 12, "Appartement > Cellier > Étagère 2"),
                item("i3", "Machine à café", .appliances, 1, "Appartement > Cuisine > Plan de travail", overdue: 1),
                item("i4", "Café en grains", .food, 1, "Appartement > Cuisine > Placard haut"),
            ]
        ),
        ItemPlaceGroup(
            id: "p2",
            placeName: "Cave",
            items: [
                item("i6", "Pot de peinture blanche", .other, 3, "Cave > Réserve > Étagère basse"),
                item("i7", "Skis", .sports, 2, "Cave > Réserve > Casier 4"),
            ]
        ),
    ]

    private static func item(
        _ id: String,
        _ name: String,
        _ category: ItemCategory,
        _ quantity: Int,
        _ path: String,
        overdue: Int = 0
    ) -> ItemListItem {
        ItemListItem(
            id: id,
            name: name,
            category: category,
            quantity: quantity,
            locationFullPath: path,
            placeId: "p1",
            placeName: "Appartement",
            roomName: "Cuisine",
            addedBy: "gallery",
            createdAt: Date(timeIntervalSince1970: 1_785_024_000),
            overdueReminderCount: overdue
        )
    }

    static let places: [Place] = [
        Place(
            id: "p1",
            name: "Appartement",
            icon: "🏠",
            order: 1,
            rooms: [
                Room(id: "r1", placeId: "p1", name: "Cuisine", icon: "🍳", order: 1, zones: [
                    Zone(id: "z1", roomId: "r1", name: "Placard haut", order: 1, itemCount: 23, storages: [
                        Storage(id: "s1", zoneId: "z1", name: "Étagère 1", order: 1),
                        Storage(id: "s2", zoneId: "z1", name: "Étagère 2", order: 2),
                    ]),
                    Zone(id: "z2", roomId: "r1", name: "Plan de travail", order: 2, itemCount: 8, storages: []),
                ]),
                Room(id: "r2", placeId: "p1", name: "Garage", icon: "🔧", order: 2, zones: [
                    Zone(id: "z3", roomId: "r2", name: "Établi", order: 1, itemCount: 41, storages: [
                        Storage(id: "s3", zoneId: "z3", name: "Tiroir 1", order: 1),
                    ]),
                ]),
            ]
        ),
        Place(
            id: "p2",
            name: "Cave",
            icon: "📦",
            order: 2,
            rooms: [
                Room(id: "r3", placeId: "p2", name: "Réserve", icon: nil, order: 1, zones: [
                    Zone(id: "z4", roomId: "r3", name: "Étagère métallique", order: 1, itemCount: 34, storages: []),
                ]),
            ]
        ),
    ]

    static let itemLocation = LocationPath(
        fullPath: "Maison > Cuisine > Placard > Étagère du haut",
        placeId: "p1",
        placeName: "Maison",
        roomId: "r1",
        roomName: "Cuisine",
        zoneId: "z1",
        zoneName: "Placard",
        storageId: "s1",
        storageName: "Étagère du haut"
    )

    static let itemReminders: [ReminderRow.Model] = [
        .init(
            id: "r1",
            title: "Détartrer",
            notes: "Vinaigre blanc, cycle complet",
            dueDate: Date(timeIntervalSinceNow: -86_400 * 3),
            isRecurring: true,
            frequencyLabel: "Tous les 3 mois",
            isOverdue: true
        ),
        .init(
            id: "r2",
            title: "Changer le filtre à eau",
            notes: "",
            dueDate: Date(timeIntervalSinceNow: 86_400 * 45),
            isRecurring: true,
            frequencyLabel: "Tous les 6 mois",
            isOverdue: false
        ),
    ]

    static let previews: [ItemPreview] = [
        ItemPreview(previewId: "pv1", name: "Boîte de conserve — tomates pelées", category: .food, description: "Conserve 400 g", quantity: 4, tags: ["tomates pelées", "conserve", "légume"], personalNotes: "", purchaseLocation: ""),
        ItemPreview(previewId: "pv2", name: "Pot d'épices", category: .food, description: "Pots de 50 g étiquetés", quantity: 12, tags: ["cumin", "paprika", "curry", "épice", "condiment", "cuisine"], personalNotes: "", purchaseLocation: ""),
        ItemPreview(previewId: "pv3", name: "Bouteille d'huile d'olive", category: .food, description: "1 L", quantity: 1, tags: ["huile d'olive", "condiment"], personalNotes: "", purchaseLocation: ""),
        ItemPreview(previewId: "pv4", name: "Rouleau d'essuie-tout", category: .other, description: "", quantity: 3, personalNotes: "", purchaseLocation: ""),
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
