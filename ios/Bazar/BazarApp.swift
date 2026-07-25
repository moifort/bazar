import SwiftUI

@main
struct BazarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if let screen = UserDefaults.standard.string(forKey: "gallery") {
                DebugGallery(screen: screen)
            } else {
                AuthRoot()
            }
            #else
            AuthRoot()
            #endif
        }
    }
}
