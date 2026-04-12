import Foundation

enum SharedConfig {
    static let serverURLKey = "serverURL"
    static let defaultURL = "http://192.168.1.206:3000"
    static let userTagKey = "userTag"

    static var serverURL: String {
        let value = UserDefaults.standard.string(forKey: serverURLKey)
        return (value?.isEmpty ?? true) ? defaultURL : value!
    }

    static var userTag: String {
        let value = UserDefaults.standard.string(forKey: userTagKey)
        return (value?.isEmpty ?? true) ? "thibaut" : value!
    }
}
