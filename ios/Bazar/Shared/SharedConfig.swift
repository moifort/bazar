import Foundation

enum SharedConfig {
    /// Override the production URL via UserDefaults["serverURL"] for local dev
    /// (e.g. when pointing the app at the Firebase emulator). Defaults to the
    /// deployed Cloud Function URL.
    static let serverURLKey = "serverURL"
    static let defaultServerURL = "https://bazar-server-PLACEHOLDER.a.run.app"

    static var serverURL: URL {
        let stored = UserDefaults.standard.string(forKey: serverURLKey)
            ?? defaultServerURL
        return URL(string: stored) ?? URL(string: defaultServerURL)!
    }
}
