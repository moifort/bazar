import Foundation

enum SharedConfig {
    static let appGroupID = "group.co.polyforms.bazar"
    static let serverURLKey = "serverURL"
    static let defaultURL = "http://localhost:3000"
    static let userTagKey = "userTag"

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static var userTag: String {
        get { sharedDefaults.string(forKey: userTagKey) ?? "anonymous" }
        set { sharedDefaults.set(newValue, forKey: userTagKey) }
    }
}
