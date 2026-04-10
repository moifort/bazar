import Apollo
import Foundation

enum GraphQLSearchAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func search(query: String, limit: Int? = nil) async throws -> [SearchEntry] {
        let gqlQuery = BazarGraphQL.SearchQuery(
            query: query,
            limit: limit.map { .some($0) } ?? .none
        )
        let data = try await GraphQLHelpers.fetch(client, query: gqlQuery)
        return data.search.map { entry in
            SearchEntry(
                type: entry.type,
                entityId: entry.entityId,
                text: entry.text
            )
        }
    }
}

@MainActor @Observable
final class SearchViewModel {
    var searchText = ""
    private(set) var results: [SearchEntry]?
    private(set) var isSearching = false

    private var searchTask: Task<Void, Never>?

    var isActive: Bool {
        !searchText.isEmpty
    }

    func onSearchTextChanged() {
        searchTask?.cancel()

        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            results = nil
            isSearching = false
            return
        }

        isSearching = true
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    private func performSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            results = nil
            isSearching = false
            return
        }

        do {
            let data = try await GraphQLSearchAPI.search(query: query)
            if !Task.isCancelled {
                results = data
            }
        } catch is CancellationError {
            // Ignored
        } catch {
            results = []
        }
        if !Task.isCancelled {
            isSearching = false
        }
    }
}
