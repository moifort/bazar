import Foundation

func reportError(_ error: Error) -> String {
    error.localizedDescription
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
