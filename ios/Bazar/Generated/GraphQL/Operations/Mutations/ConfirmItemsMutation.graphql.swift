// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class ConfirmItemsMutation: GraphQLMutation {
    static let operationName: String = "ConfirmItems"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation ConfirmItems($input: [ConfirmItemInput!]!) { confirmItems(input: $input) { __typename id name category quantity createdAt } }"#
      ))

    public var input: [ConfirmItemInput]

    public init(input: [ConfirmItemInput]) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("confirmItems", [ConfirmItem].self, arguments: ["input": .variable("input")]),
      ] }

      /// Confirm and create items from a scan preview
      var confirmItems: [ConfirmItem] { __data["confirmItems"] }

      /// ConfirmItem
      ///
      /// Parent Type: `Item`
      struct ConfirmItem: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Item }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.ItemId.self),
          .field("name", BazarGraphQL.ItemName.self),
          .field("category", GraphQLEnum<BazarGraphQL.ItemCategory>.self),
          .field("quantity", BazarGraphQL.Quantity.self),
          .field("createdAt", BazarGraphQL.DateTime.self),
        ] }

        /// Item unique identifier
        var id: BazarGraphQL.ItemId { __data["id"] }
        /// Item display name
        var name: BazarGraphQL.ItemName { __data["name"] }
        /// Item category
        var category: GraphQLEnum<BazarGraphQL.ItemCategory> { __data["category"] }
        /// Number of identical items
        var quantity: BazarGraphQL.Quantity { __data["quantity"] }
        /// Creation date
        var createdAt: BazarGraphQL.DateTime { __data["createdAt"] }
      }
    }
  }

}