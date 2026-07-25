import Foundation

/// The photo-scan allowance for the current month. `limit` is absent on Premium —
/// the server says "no monthly limit" with a null, and the app says it with `nil`.
struct QuotaState: Sendable {
    let isPremium: Bool
    let used: Int
    let limit: Int?
    let remaining: Int?
    let renewsOn: Date?
}
