import Apollo
import ApolloAPI
import FirebaseAuth
import Foundation

extension HTTPRequest: @retroactive @unchecked Sendable {}
extension HTTPResponse: @retroactive @unchecked Sendable {}

/// Injects the current Firebase user's ID token into every GraphQL request as
/// `Authorization: Bearer <token>`. Firebase Auth refreshes the token under
/// the hood so this is always fresh.
struct FirebaseTokenInterceptor: ApolloInterceptor {
    let id = UUID().uuidString

    func interceptAsync<Operation: GraphQLOperation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            chain.proceedAsync(
                request: request,
                response: response,
                interceptor: self,
                completion: completion
            )
            return
        }
        currentUser.getIDToken { token, error in
            if let error {
                chain.handleErrorAsync(
                    error,
                    request: request,
                    response: response,
                    completion: completion
                )
                return
            }
            if let token {
                request.addHeader(name: "Authorization", value: "Bearer \(token)")
            }
            chain.proceedAsync(
                request: request,
                response: response,
                interceptor: self,
                completion: completion
            )
        }
    }
}
