import Foundation

final class APIClient: Sendable {
    static let shared = APIClient()

    var baseURL: URL {
        let stored = SharedConfig.sharedDefaults.string(forKey: SharedConfig.serverURLKey)
            ?? SharedConfig.defaultURL
        return URL(string: stored) ?? URL(string: SharedConfig.defaultURL)!
    }

    private let session = URLSession.shared

    private func authenticatedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(Secrets.apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue(SharedConfig.userTag, forHTTPHeaderField: "X-User")
        return request
    }

    func upload(_ path: String, imageData: Data) async throws -> Data {
        var request = authenticatedRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return data
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(http.statusCode)
        }
    }
}
