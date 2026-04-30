// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class UnsubscribeFromNotificationsMutation: GraphQLMutation {
    static let operationName: String = "UnsubscribeFromNotifications"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UnsubscribeFromNotifications($token: String!) { unsubscribeFromNotifications(token: $token) }"#
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
        .field("unsubscribeFromNotifications", Bool.self, arguments: ["token": .variable("token")]),
      ] }

      /// Unregister an FCM device token from push notifications
      var unsubscribeFromNotifications: Bool { __data["unsubscribeFromNotifications"] }
    }
  }

}