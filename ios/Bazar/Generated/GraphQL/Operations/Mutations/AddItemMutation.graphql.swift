// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class AddItemMutation: GraphQLMutation {
    static let operationName: String = "AddItem"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AddItem($input: AddItemInput!) { addItem(input: $input) { __typename id name category quantity createdAt } }"#
      ))

    public var input: AddItemInput

    public init(input: AddItemInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("addItem", AddItem.self, arguments: ["input": .variable("input")]),
      ] }

      /// Manually add a new item to the inventory
      var addItem: AddItem { __data["addItem"] }

      /// AddItem
      ///
      /// Parent Type: `Item`
      struct AddItem: BazarGraphQL.SelectionSet {
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