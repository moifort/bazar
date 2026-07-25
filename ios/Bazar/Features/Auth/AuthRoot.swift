import SwiftUI

/// Top-level gate: shows LoginView when no Firebase user is signed in,
/// otherwise the main TabView (`ContentView`).
struct AuthRoot: View {
    @State private var session = AuthSession()
    /// App-scoped: StoreKit's transaction listener must live for the whole run,
    /// and every screen that sells or gates reads the same answer.
    @State private var subscription = SubscriptionStore()

    var body: some View {
        Group {
            if session.user == nil {
                LoginView()
            } else {
                ContentView()
            }
        }
        .environment(session)
        .environment(subscription)
    }
}
