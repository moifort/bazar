import FirebaseCore
import SwiftUI

@main
struct BazarApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AuthRoot()
        }
    }
}
