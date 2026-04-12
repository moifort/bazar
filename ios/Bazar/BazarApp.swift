import SwiftUI

@main
struct BazarApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            SharedConfig.serverURLKey: SharedConfig.defaultURL,
            SharedConfig.userTagKey: "thibaut",
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
