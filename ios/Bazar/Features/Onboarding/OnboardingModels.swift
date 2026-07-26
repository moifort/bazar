import Foundation

/// A room the onboarding offers to create in one tap. The icon is the emoji the
/// room is stored with, the same one the Lieux tab shows afterwards.
struct SuggestedRoom: Identifiable, Sendable, Hashable {
    let name: String
    let icon: String

    var id: String { name }
}

enum SuggestedRooms {
    /// The rooms a French home usually has, most common first. The first four
    /// come pre-selected: a user who taps straight through still ends up with
    /// somewhere to put things.
    static let all: [SuggestedRoom] = [
        SuggestedRoom(name: "Cuisine", icon: "🍳"),
        SuggestedRoom(name: "Salon", icon: "🛋️"),
        SuggestedRoom(name: "Chambre", icon: "🛏️"),
        SuggestedRoom(name: "Salle de bain", icon: "🛁"),
        SuggestedRoom(name: "Entrée", icon: "🚪"),
        SuggestedRoom(name: "Bureau", icon: "💻"),
        SuggestedRoom(name: "Garage", icon: "🔧"),
        SuggestedRoom(name: "Cave", icon: "📦"),
        SuggestedRoom(name: "Buanderie", icon: "🧺"),
        SuggestedRoom(name: "Terrasse", icon: "🪴"),
    ]

    static let preselected: Set<String> = Set(all.prefix(4).map(\.name))
}

/// What the server answers about a launch: the name it already knows, and
/// whether the account owns a place already — an account created before the
/// onboarding existed does, and must not be offered a second house.
struct OnboardingState: Sendable {
    let firstName: String?
    let hasPlace: Bool
}
