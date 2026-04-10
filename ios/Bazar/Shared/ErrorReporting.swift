import Foundation

func reportError(_ error: Error) -> String {
    error.localizedDescription
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "Réponse invalide du serveur"
        case .httpError(let code): "Erreur HTTP \(code)"
        }
    }
}
