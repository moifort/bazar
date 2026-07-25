import Foundation

/// One version section of the application changelog.
struct ChangelogVersion: Identifiable, Sendable {
    let version: String
    let date: Date?
    let notes: [String]

    var id: String { version }
}
