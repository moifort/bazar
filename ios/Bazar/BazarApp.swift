import SwiftUI

@main
struct BazarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AuthRoot()
        }
    }
}
