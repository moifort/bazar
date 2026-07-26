import Apollo
import Foundation

enum OnboardingAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    /// The house the onboarding creates always carries this icon: the step asks
    /// for a name, not for an emoji.
    static let houseIcon = "🏠"

    static func state() async throws -> OnboardingState {
        let data = try await GraphQLHelpers.fetch(client, query: BazarGraphQL.OnboardingStateQuery())
        return OnboardingState(firstName: data.me?.firstName, hasPlace: !data.places.isEmpty)
    }

    static func complete(
        firstName: String,
        houseName: String?,
        rooms: [SuggestedRoom]
    ) async throws {
        let input = BazarGraphQL.CompleteOnboardingInput(
            firstName: firstName,
            houseIcon: GraphQLHelpers.graphQLNullable(houseName.map { _ in houseIcon }),
            houseName: GraphQLHelpers.graphQLNullable(houseName),
            rooms: rooms.map { BazarGraphQL.OnboardingRoomInput(icon: .some($0.icon), name: $0.name) }
        )
        _ = try await GraphQLHelpers.perform(
            client,
            mutation: BazarGraphQL.CompleteOnboardingMutation(input: input)
        )
    }
}
