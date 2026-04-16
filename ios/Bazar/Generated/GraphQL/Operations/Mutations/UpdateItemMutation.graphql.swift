// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class UpdateItemMutation: GraphQLMutation {
    static let operationName: String = "UpdateItem"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateItem($id: ItemId!, $input: UpdateItemInput!) { updateItem(id: $id, input: $input) { __typename id name category quantity purchaseDate purchaseLocation invoiceImageId updatedAt } }"#
      ))

    public var id: ItemId
    public var input: UpdateItemInput

    public init(
      id: ItemId,
      input: UpdateItemInput
    ) {
      self.id = id
      self.input = input
    }

    public var __variables: Variables? { [
      "id": id,
      "input": input
    ] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("updateItem", UpdateItem.self, arguments: [
          "id": .variable("id"),
          "input": .variable("input")
        ]),
      ] }

      /// Update an existing item
      var updateItem: UpdateItem { __data["updateItem"] }

      /// UpdateItem
      ///
      /// Parent Type: `Item`
      struct UpdateItem: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Item }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.ItemId.self),
          .field("name", BazarGraphQL.ItemName.self),
          .field("category", GraphQLEnum<BazarGraphQL.ItemCategory>.self),
          .field("quantity", BazarGraphQL.Quantity.self),
          .field("purchaseDate", BazarGraphQL.DateTime?.self),
          .field("purchaseLocation", String.self),
          .field("invoiceImageId", BazarGraphQL.ImageId?.self),
          .field("updatedAt", BazarGraphQL.DateTime.self),
        ] }

        /// Item unique identifier
        var id: BazarGraphQL.ItemId { __data["id"] }
        /// Item display name
        var name: BazarGraphQL.ItemName { __data["name"] }
        /// Item category
        var category: GraphQLEnum<BazarGraphQL.ItemCategory> { __data["category"] }
        /// Number of identical items
        var quantity: BazarGraphQL.Quantity { __data["quantity"] }
        /// Date this item was purchased
        var purchaseDate: BazarGraphQL.DateTime? { __data["purchaseDate"] }
        /// Where the item was purchased (e.g. "Amazon", "Leroy Merlin")
        var purchaseLocation: String { __data["purchaseLocation"] }
        /// Invoice photo image identifier
        var invoiceImageId: BazarGraphQL.ImageId? { __data["invoiceImageId"] }
        /// Last update date
        var updatedAt: BazarGraphQL.DateTime { __data["updatedAt"] }
      }
    }
  }

}