// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class SubscribeToNotificationsMutation: GraphQLMutation {
    static let operationName: String = "SubscribeToNotifications"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation SubscribeToNotifications($token: String!) { subscribeToNotifications(token: $token) }"#
      ))

    public var token: String

    public init(token: String) {
      self.token = token
    }

    public var __variables: Variables? { ["token": token] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("subscribeToNotifications", Bool.self, arguments: ["token": .variable("token")]),
      ] }

      /// Register an FCM device token for push notifications
      var subscribeToNotifications: Bool { __data["subscribeToNotifications"] }
    }
  }

}