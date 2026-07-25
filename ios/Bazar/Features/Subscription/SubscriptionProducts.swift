import Foundation

/// The two subscriptions sold, as declared in App Store Connect and mirrored in
/// `ios/Bazar.storekit` for local testing. The identifiers must match all three
/// places exactly — a typo simply makes the product fail to load, silently.
enum SubscriptionProducts {
    static let yearly = "co.polyforms.bazar.premium.yearly"
    static let monthly = "co.polyforms.bazar.premium.monthly"

    /// Yearly first: it is the offer the sheet puts forward.
    static let all = [yearly, monthly]
}
