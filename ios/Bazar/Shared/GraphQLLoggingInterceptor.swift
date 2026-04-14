import Apollo
import ApolloAPI
import Foundation
import OSLog

private let networkLog = Logger(subsystem: "co.polyforms.bazar", category: "graphql.network")

final class GraphQLLoggingInterceptor: ApolloInterceptor {
    let id: String = UUID().uuidString

    func interceptAsync<Operation: GraphQLOperation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        let name = Operation.operationName
        let url = request.graphQLEndpoint.absoluteString
        networkLog.debug("→ \(name, privacy: .public) POST \(url, privacy: .public)")

        chain.proceedAsync(request: request, response: response, interceptor: self) { result in
            switch result {
            case .success(let graphQLResult):
                let status = response?.httpResponse.statusCode ?? -1
                let errorCount = graphQLResult.errors?.count ?? 0
                if errorCount > 0 {
                    networkLog.error("← \(name, privacy: .public) HTTP \(status) with \(errorCount) GraphQL error(s)")
                } else {
                    networkLog.debug("← \(name, privacy: .public) HTTP \(status) ok")
                }
            case .failure(let error):
                networkLog.error("← \(name, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
            }
            completion(result)
        }
    }
}

final class LoggingInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
    ) -> [any ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(GraphQLLoggingInterceptor(), at: 0)
        return interceptors
    }
}
