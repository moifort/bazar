import SwiftUI

struct HouseStep: View {
    @Binding var houseName: String

    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 12) {
            TextField("Maison", text: $houseName)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .font(.title3)
                .multilineTextAlignment(.center)
                .focused($focused)
                .accessibilityIdentifier("onboarding-house-name")

            Text("Appartement, maison de vacances, cave, bureau : tu pourras en ajouter d'autres.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .task { focused = true }
    }
}

#Preview("Vide") {
    HouseStep(houseName: .constant(""))
}

#Preview("Rempli") {
    HouseStep(houseName: .constant("Appartement"))
}
