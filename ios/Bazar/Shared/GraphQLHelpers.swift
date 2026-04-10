import Apollo
import Foundation

enum GraphQLHelpers {
    static func fetch<Q: GraphQLQuery>(_ client: ApolloClient, query: Q) async throws -> Q.Data {
        try await withCheckedThrowingContinuation { continuation in
            client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors, !errors.isEmpty {
                        continuation.resume(throwing: APIError.httpError(422))
                        return
                    }
                    guard let data = graphQLResult.data else {
                        continuation.resume(throwing: APIError.invalidResponse)
                        return
                    }
                    nonisolated(unsafe) let sendableData = data
                    continuation.resume(returning: sendableData)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    static func perform<M: GraphQLMutation>(_ client: ApolloClient, mutation: M) async throws -> M.Data {
        try await withCheckedThrowingContinuation { continuation in
            client.perform(mutation: mutation) { result in
                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors, !errors.isEmpty {
                        continuation.resume(throwing: APIError.httpError(422))
                        return
                    }
                    guard let data = graphQLResult.data else {
                        continuation.resume(throwing: APIError.invalidResponse)
                        return
                    }
                    nonisolated(unsafe) let sendableData = data
                    continuation.resume(returning: sendableData)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    static func parseISO8601(_ string: String) -> Date? {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let withoutFraction = ISO8601DateFormatter()
        withoutFraction.formatOptions = [.withInternetDateTime]
        return withFraction.date(from: string) ?? withoutFraction.date(from: string)
    }

    static func graphQLNullable<T>(_ value: T?) -> GraphQLNullable<T> {
        value.map { .some($0) } ?? .none
    }
}
