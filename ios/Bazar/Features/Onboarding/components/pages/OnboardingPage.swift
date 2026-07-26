import SwiftUI

/// The first launch, in three screens: how to call you, what your first house is
/// called, and which rooms it has. Pure presentation — the coordinator decides
/// what "continue" means at each step.
struct OnboardingPage: View {
    enum Step: Hashable {
        case name
        case house
        case rooms
    }

    let step: Step
    @Binding var firstName: String
    @Binding var houseName: String
    @Binding var selectedRooms: Set<String>
    let suggestedRooms: [SuggestedRoom]
    let continueLabel: String
    let canContinue: Bool
    let isSubmitting: Bool
    let errorMessage: String?
    let onContinue: () -> Void
    let onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            header
            content
            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            footer
        }
        .padding(.top, 48)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(.tint)
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .name:
            Spacer()
            FirstNameStep(firstName: $firstName)
            Spacer()
        case .house:
            Spacer()
            HouseStep(houseName: $houseName)
            Spacer()
        case .rooms:
            RoomsStep(rooms: suggestedRooms, selected: $selectedRooms)
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Button(action: onContinue) {
                Group {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(continueLabel)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canContinue || isSubmitting)
            .accessibilityIdentifier("onboarding-continue")

            if let onBack {
                Button("Retour", action: onBack)
                    .disabled(isSubmitting)
            }
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 24)
    }

    private var icon: String {
        switch step {
        case .name: "hand.wave"
        case .house: "house"
        case .rooms: "square.split.bottomrightquarter"
        }
    }

    private var title: String {
        switch step {
        case .name: "Bienvenue"
        case .house: "Ta première maison"
        case .rooms: "Ses pièces"
        }
    }

    private var subtitle: String {
        switch step {
        case .name: "Comment doit-on t'appeler ?"
        case .house: "Donne-lui un nom : c'est là que tes objets seront rangés."
        case .rooms: "Coche celles qui existent, tu compléteras plus tard."
        }
    }
}

private struct OnboardingPagePreview: View {
    let step: OnboardingPage.Step
    var isSubmitting = false
    var errorMessage: String?

    @State private var firstName = "Thibaut"
    @State private var houseName = "Appartement"
    @State private var selectedRooms = SuggestedRooms.preselected

    var body: some View {
        OnboardingPage(
            step: step,
            firstName: $firstName,
            houseName: $houseName,
            selectedRooms: $selectedRooms,
            suggestedRooms: SuggestedRooms.all,
            continueLabel: step == .rooms ? "Terminer" : "Continuer",
            canContinue: true,
            isSubmitting: isSubmitting,
            errorMessage: errorMessage,
            onContinue: {},
            onBack: step == .name ? nil : {}
        )
    }
}

#Preview("Prénom") {
    OnboardingPagePreview(step: .name)
}

#Preview("Maison") {
    OnboardingPagePreview(step: .house)
}

#Preview("Pièces") {
    OnboardingPagePreview(step: .rooms)
}

#Preview("Envoi en cours") {
    OnboardingPagePreview(step: .rooms, isSubmitting: true)
}

#Preview("Erreur") {
    OnboardingPagePreview(step: .rooms, errorMessage: "Le serveur n'a pas répondu.")
}
