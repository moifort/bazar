import SwiftUI

struct AsyncToolbarButton: View {
    let title: String
    let systemImage: String
    var role: ButtonRole? = nil
    let action: () async -> Void

    @State private var isInProgress = false

    var body: some View {
        Button(role: role) {
            guard !isInProgress else { return }
            isInProgress = true
            Task {
                await action()
                isInProgress = false
            }
        } label: {
            if isInProgress {
                ProgressView()
            } else {
                Label(title, systemImage: systemImage)
            }
        }
        .disabled(isInProgress)
    }
}

#Preview {
    NavigationStack {
        Text("Content")
            .toolbar {
                AsyncToolbarButton(title: "Enregistrer", systemImage: "checkmark") {
                    try? await Task.sleep(for: .seconds(2))
                }
                AsyncToolbarButton(title: "Supprimer", systemImage: "trash", role: .destructive) {
                    try? await Task.sleep(for: .seconds(2))
                }
            }
    }
}
