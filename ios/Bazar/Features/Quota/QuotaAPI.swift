import Apollo
import Foundation

enum QuotaAPI {
    /// The photo-scan allowance for the current month — the plan, the counter and
    /// the renewal date.
    static func load() async throws -> QuotaState {
        let data = try await GraphQLHelpers.fetch(
            GraphQLClient.shared.apollo,
            query: BazarGraphQL.QuotaQuery()
        )
        let quota = data.quota
        return QuotaState(
            isPremium: quota.plan.value == .premium,
            used: quota.used,
            limit: quota.limit,
            remaining: quota.remaining,
            renewsOn: GraphQLHelpers.parseISO8601(quota.renewsOn)
        )
    }
}
