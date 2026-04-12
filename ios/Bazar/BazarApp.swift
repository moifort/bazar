import SwiftUI

@main
struct BazarApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            SharedConfig.serverURLKey: SharedConfig.defaultURL,
            SharedConfig.userTagKey: "thibaut",
        ])
        SharedConfig.sharedDefaults.register(defaults: [SharedConfig.serverURLKey: SharedConfig.defaultURL])
        if let override = UserDefaults.standard.string(forKey: SharedConfig.serverURLKey) {
            SharedConfig.sharedDefaults.set(override, forKey: SharedConfig.serverURLKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
