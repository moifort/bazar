import Apollo
import ApolloAPI
import Foundation

final class GraphQLClient: @unchecked Sendable {
    static let shared = GraphQLClient()

    var apollo: ApolloClient {
        let url = APIClient.shared.baseURL.appendingPathComponent("graphql")

        let store = ApolloStore()
        let interceptorProvider = LoggingInterceptorProvider(store: store)
        let transport = RequestChainNetworkTransport(
            interceptorProvider: interceptorProvider,
            endpointURL: url,
            additionalHeaders: [
                "Authorization": "Bearer \(Secrets.apiToken)",
                "X-User": SharedConfig.userTag,
            ]
        )

        return ApolloClient(networkTransport: transport, store: store)
    }

    private init() {}
}
