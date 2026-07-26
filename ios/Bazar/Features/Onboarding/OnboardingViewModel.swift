import Foundation

@MainActor @Observable
final class OnboardingViewModel {
    /// `unknown` while the server has not answered yet — the app shows nothing
    /// rather than flashing an onboarding at a user who already did it.
    enum Status: Equatable, Sendable {
        case unknown
        case needed(hasPlace: Bool)
        case done
    }

    private(set) var status: Status = .unknown
    var error: String?
    private var isLoading = false

    func load() async {
        guard !isLoading, status == .unknown else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let state = try await OnboardingAPI.state()
            status = state.firstName == nil ? .needed(hasPlace: state.hasPlace) : .done
        } catch is CancellationError {
            // Ignored — the task was cancelled, the next launch of it will ask again.
        } catch {
            // Fail open: a server that hiccups must not wall the app behind an
            // onboarding nobody can get through.
            _ = reportError(error)
            status = .done
        }
    }

    /// Signing out drops what we know: the next account to sign in on this phone
    /// asks the server for itself.
    func reset() {
        status = .unknown
        error = nil
    }

    func complete(firstName: String, houseName: String?, rooms: [SuggestedRoom]) async {
        error = nil
        do {
            try await OnboardingAPI.complete(
                firstName: firstName,
                houseName: houseName,
                rooms: rooms
            )
            status = .done
        } catch {
            self.error = reportError(error)
        }
    }
}
