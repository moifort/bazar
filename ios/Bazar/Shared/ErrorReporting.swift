import Foundation
import Sentry

/// Starts error reporting for release builds only. A crash from the simulator,
/// the debug gallery or a preview is not an incident; letting it into the same
/// stream as real ones buries the reports that matter under noise nobody will
/// triage. This mirrors the backend, where the DSN only exists in production's
/// Secret Manager and is simply absent everywhere else.
func startErrorReporting() {
    #if !DEBUG
    guard SharedConfig.sentryDSN.hasPrefix("https://") else { return }
    SentrySDK.start { options in
        options.dsn = SharedConfig.sentryDSN
        options.environment = "production"
    }
    #endif
}

func reportError(_ error: Error) -> String {
    // No-op when the SDK was never started (DEBUG, blank DSN), so this is
    // always safe to call.
    SentrySDK.capture(error: error)
    return error.localizedDescription
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpError(Int)
    case graphQL(messages: [String])

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "Réponse invalide du serveur"
        case .httpError(let code): "Erreur HTTP \(code)"
        case .graphQL(let messages):
            messages.isEmpty ? "Erreur GraphQL inconnue" : messages.joined(separator: "\n")
        }
    }
}
