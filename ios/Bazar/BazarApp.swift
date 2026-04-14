import SwiftUI

@main
struct BazarApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            SharedConfig.environmentKey: SharedConfig.defaultEnvironment.rawValue,
            SharedConfig.devServerURLKey: SharedConfig.defaultDevURL,
            SharedConfig.productionURLKey: SharedConfig.productionURL,
            SharedConfig.userTagKey: SharedConfig.defaultUserTag,
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
