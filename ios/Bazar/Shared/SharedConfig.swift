import Foundation

enum SharedConfig {
    static let appGroupID = "group.co.polyforms.bazar"
    static let serverURLKey = "serverURL"
    static let defaultURL = "http://192.168.1.206:3000"
    static let userTagKey = "userTag"

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static var userTag: String {
        get {
            let value = UserDefaults.standard.string(forKey: userTagKey)
            return (value?.isEmpty ?? true) ? "thibaut" : value!
        }
    }
}
