// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class DeleteAccountMutation: GraphQLMutation {
    static let operationName: String = "DeleteAccount"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeleteAccount { deleteAccount }"#
      ))

    public init() {}

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("deleteAccount", Bool.self),
      ] }

      /// Delete your account and everything the app holds on you: your first name, every item, every place, room, zone and storage spot, every reminder and its completion history, and every device registered for notifications. IRREVERSIBLE and immediate — there is no grace period and no way back. Returns `true` once it is done.
      ///
      /// ```graphql
      /// deleteAccount
      /// ```
      var deleteAccount: Bool { __data["deleteAccount"] }
    }
  }

}