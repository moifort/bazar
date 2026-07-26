import SwiftUI

/// Top-level gate: shows LoginView when no Firebase user is signed in, then the
/// onboarding until the user has introduced themselves, and only then the main
/// TabView (`ContentView`).
struct AuthRoot: View {
    @State private var session = AuthSession()
    /// App-scoped: StoreKit's transaction listener must live for the whole run,
    /// and every screen that sells or gates reads the same answer.
    @State private var subscription = SubscriptionStore()
    /// App-scoped too: the answer is asked once per signed-in account, not once
    /// per screen that happens to appear.
    @State private var onboarding = OnboardingViewModel()

    var body: some View {
        Group {
            if session.user == nil {
                LoginView()
            } else {
                switch onboarding.status {
                case .unknown:
                    ProgressView()
                case .needed(let hasPlace):
                    OnboardingView(
                        viewModel: onboarding,
                        hasPlace: hasPlace,
                        suggestedFirstName: session.suggestedFirstName
                    )
                case .done:
                    ContentView()
                }
            }
        }
        .task(id: session.user?.uid) {
            guard session.user != nil else { return onboarding.reset() }
            await onboarding.load()
        }
        .environment(session)
        .environment(subscription)
    }
}
