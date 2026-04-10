import SwiftUI

@main
struct BazarApp: App {
    init() {
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
