import Apollo
import ApolloAPI
import Foundation

final class GraphQLClient: @unchecked Sendable {
    static let shared = GraphQLClient()

    let apollo: ApolloClient

    private init() {
        let url = APIClient.shared.baseURL.appendingPathComponent("graphql")

        let store = ApolloStore()
        let interceptorProvider = DefaultInterceptorProvider(store: store)
        let transport = RequestChainNetworkTransport(
            interceptorProvider: interceptorProvider,
            endpointURL: url,
            additionalHeaders: [
                "Authorization": "Bearer \(Secrets.apiToken)",
                "X-User": SharedConfig.userTag,
            ]
        )

        apollo = ApolloClient(networkTransport: transport, store: store)
    }
}
