import SwiftUI

struct FirstNameStep: View {
    @Binding var firstName: String

    @FocusState private var focused: Bool

    var body: some View {
        TextField("Ton prénom", text: $firstName)
            .textFieldStyle(.roundedBorder)
            .textContentType(.givenName)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .font(.title3)
            .multilineTextAlignment(.center)
            .focused($focused)
            .accessibilityIdentifier("onboarding-first-name")
            .padding(.horizontal, 32)
            .task { focused = true }
    }
}

#Preview("Vide") {
    FirstNameStep(firstName: .constant(""))
}

#Preview("Rempli") {
    FirstNameStep(firstName: .constant("Thibaut"))
}
