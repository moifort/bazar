import Apollo
import Foundation

enum SettingsAPI {
    static func loadChangelog() async throws -> [ChangelogVersion] {
        let data = try await GraphQLHelpers.fetch(
            GraphQLClient.shared.apollo,
            query: BazarGraphQL.ChangelogQuery()
        )
        return data.changelog.map { entry in
            ChangelogVersion(
                version: entry.version,
                date: entry.date.flatMap { GraphQLHelpers.parseISO8601($0) },
                notes: entry.notes
            )
        }
    }

    static func deleteAccount() async throws {
        _ = try await GraphQLHelpers.perform(
            GraphQLClient.shared.apollo,
            mutation: BazarGraphQL.DeleteAccountMutation()
        )
    }
}
