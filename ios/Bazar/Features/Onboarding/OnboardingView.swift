import SwiftUI

/// Coordinator of the first launch: owns the step the user is on, what they
/// typed, and the single mutation that closes the whole thing.
struct OnboardingView: View {
    let viewModel: OnboardingViewModel
    /// An account that already owns places (one created before the onboarding
    /// existed) is only asked for a first name — offering it a first house would
    /// hand it a duplicate.
    let hasPlace: Bool
    let suggestedFirstName: String?

    @State private var step: OnboardingPage.Step = .name
    @State private var firstName = ""
    @State private var houseName = ""
    @State private var selectedRooms = SuggestedRooms.preselected
    @State private var isSubmitting = false

    var body: some View {
        OnboardingPage(
            step: step,
            firstName: $firstName,
            houseName: $houseName,
            selectedRooms: $selectedRooms,
            suggestedRooms: SuggestedRooms.all,
            continueLabel: isLastStep ? "Terminer" : "Continuer",
            canContinue: canContinue,
            isSubmitting: isSubmitting,
            errorMessage: viewModel.error,
            onContinue: { advance() },
            onBack: step == .name ? nil : { back() }
        )
        .task {
            if firstName.isEmpty, let suggestedFirstName {
                firstName = suggestedFirstName
            }
        }
    }

    private var trimmedFirstName: String {
        firstName.trimmingCharacters(in: .whitespaces)
    }

    private var trimmedHouseName: String {
        houseName.trimmingCharacters(in: .whitespaces)
    }

    private var isLastStep: Bool {
        switch step {
        case .name: hasPlace
        case .house: false
        case .rooms: true
        }
    }

    private var canContinue: Bool {
        switch step {
        case .name: !trimmedFirstName.isEmpty
        case .house: !trimmedHouseName.isEmpty
        case .rooms: true
        }
    }

    private func advance() {
        switch step {
        case .name:
            if hasPlace {
                submit()
            } else {
                withAnimation { step = .house }
            }
        case .house:
            withAnimation { step = .rooms }
        case .rooms:
            submit()
        }
    }

    private func back() {
        withAnimation { step = step == .rooms ? .house : .name }
    }

    private func submit() {
        guard !isSubmitting else { return }
        isSubmitting = true
        Task {
            await viewModel.complete(
                firstName: trimmedFirstName,
                houseName: hasPlace ? nil : trimmedHouseName,
                rooms: hasPlace ? [] : SuggestedRooms.all.filter { selectedRooms.contains($0.name) }
            )
            isSubmitting = false
        }
    }
}
