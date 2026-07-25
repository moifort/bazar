import FirebaseAuth
import Observation

/// Single source of truth for the currently authenticated Firebase user.
/// Lives at app scope; views that need to react to sign-in/out observe `user`.
@MainActor
@Observable
final class AuthSession {
    private(set) var user: User?
    @ObservationIgnored
    nonisolated(unsafe) private var handle: AuthStateDidChangeListenerHandle?

    init() {
        user = Auth.auth().currentUser
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.user = user }
        }
    }

    deinit {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    /// Apple requires an app that signs users in with Apple to revoke that token when
    /// the account goes. The revocation needs a fresh authorization code — the one from
    /// sign-in is handed out once and never stored — so the Apple sheet runs again
    /// first. Data is erased server-side before the local session ends.
    func deleteAccount() async throws {
        let code = try await AppleReauthentication().authorizationCode()
        try await Auth.auth().revokeToken(withAuthorizationCode: code)
        try await SettingsAPI.deleteAccount()
        try Auth.auth().signOut()
    }
}
