import SwiftUI

/// Settings coordinator: owns the navigation stack, the session and every network
/// call the settings screens make. The pages below it stay pure.
struct SettingsView: View {
    @Environment(AuthSession.self) private var authSession
    @Environment(\.dismiss) private var dismiss

    @State private var path: [Route] = []
    @State private var entries: [ChangelogVersion] = []
    @State private var changelogLoading = true
    @State private var changelogError: String?
    @State private var isDeleting = false
    @State private var actionError: String?

    private enum Route: Hashable { case changelog }

    var body: some View {
        NavigationStack(path: $path) {
            SettingsHomePage(
                appVersion: appVersion,
                buildNumber: buildNumber,
                email: authSession.user?.email,
                isDeleting: isDeleting,
                onChangelog: { path.append(.changelog) },
                onSignOut: signOut,
                onDeleteAccount: { Task { await deleteAccount() } },
                onClose: { dismiss() }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .changelog:
                    ChangelogPage(
                        entries: entries,
                        isLoading: changelogLoading,
                        error: changelogError,
                        onRefresh: loadChangelog
                    )
                    .task { await loadChangelog() }
                }
            }
        }
        .alert(
            "Erreur",
            isPresented: Binding(get: { actionError != nil }, set: { if !$0 { actionError = nil } })
        ) {
            Button("OK") { actionError = nil }
        } message: {
            Text(actionError ?? "")
        }
    }

    private func loadChangelog() async {
        do {
            entries = try await SettingsAPI.loadChangelog()
            changelogError = nil
        } catch {
            changelogError = reportError(error)
        }
        changelogLoading = false
    }

    private func signOut() {
        do {
            try authSession.signOut()
            dismiss()
        } catch {
            actionError = reportError(error)
        }
    }

    private func deleteAccount() async {
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await authSession.deleteAccount()
            dismiss()
        } catch AppleReauthentication.Failure.canceled {
            // Backing out of the Apple sheet is a decision, not a failure: nothing
            // has been deleted, and an error alert would suggest otherwise.
        } catch {
            actionError = reportError(error)
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
    }
}
