import SwiftUI

/// Pure presentation: the settings list. Every action is a callback — the
/// coordinator owns the navigation, the network and the session.
struct SettingsHomePage: View {
    let appVersion: String
    let buildNumber: String
    let email: String?
    let isDeleting: Bool
    /// Absent until the allowance answers — the section stays out of the list
    /// rather than showing an empty gauge.
    let quota: QuotaState?
    let onChangelog: () -> Void
    let onUpgrade: () -> Void
    let onSignOut: () -> Void
    let onDeleteAccount: () -> Void
    let onClose: () -> Void

    @State private var confirmDelete = false

    var body: some View {
        List {
            Section("Application") {
                Button(action: onChangelog) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Nouveautés")
                            Text("v\(appVersion) (\(buildNumber))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "doc.text.fill").foregroundStyle(.indigo)
                    }
                }
                .tint(.primary)
                .accessibilityIdentifier("changelog-button")
            }

            if let quota {
                QuotaSection(
                    isPremium: quota.isPremium,
                    used: quota.used,
                    limit: quota.limit,
                    renewsOn: quota.renewsOn,
                    onUpgrade: onUpgrade
                )
            }

            Section("Compte") {
                if let email {
                    Text(email).foregroundStyle(.secondary)
                }
                Button(role: .destructive) {
                    confirmDelete = true
                } label: {
                    HStack {
                        Text("Supprimer mon compte")
                        if isDeleting {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(isDeleting)
                .accessibilityIdentifier("delete-account-button")
            }

            Section {
                Button("Se déconnecter", role: .destructive, action: onSignOut)
                    .accessibilityIdentifier("sign-out-button")
            }
        }
        .navigationTitle("Réglages")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel("Fermer")
            }
        }
        // Everything the deletion takes is named before the button is pressed,
        // not discovered afterwards — there is no way back from it.
        .alert("Supprimer mon compte ?", isPresented: $confirmDelete) {
            Button("Supprimer définitivement", role: .destructive, action: onDeleteAccount)
            Button("Annuler", role: .cancel) {}
        } message: {
            Text(
                "Tous vos objets, vos lieux et vos rappels seront effacés définitivement. "
                    + "Cette action est irréversible."
            )
        }
    }
}

#Preview("Réglages") {
    NavigationStack {
        SettingsHomePage(
            appVersion: "1.0.0",
            buildNumber: "1",
            email: "thibaut@example.com",
            isDeleting: false,
            quota: QuotaState(
                isPremium: false,
                used: 7,
                limit: 10,
                remaining: 3,
                renewsOn: Date(timeIntervalSince1970: 1_785_888_000)
            ),
            onChangelog: {},
            onUpgrade: {},
            onSignOut: {},
            onDeleteAccount: {},
            onClose: {}
        )
    }
}

#Preview("Suppression en cours") {
    NavigationStack {
        SettingsHomePage(
            appVersion: "1.0.0",
            buildNumber: "1",
            email: "thibaut@example.com",
            isDeleting: true,
            quota: nil,
            onChangelog: {},
            onUpgrade: {},
            onSignOut: {},
            onDeleteAccount: {},
            onClose: {}
        )
    }
}
