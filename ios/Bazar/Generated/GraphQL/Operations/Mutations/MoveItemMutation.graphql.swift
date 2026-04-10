// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class MoveItemMutation: GraphQLMutation {
    static let operationName: String = "MoveItem"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation MoveItem($id: ItemId!, $storageId: StorageId!) { moveItem(id: $id, storageId: $storageId) { __typename id name location { __typename fullPath } } }"#
      ))

    public var id: ItemId
    public var storageId: StorageId

    public init(
      id: ItemId,
      storageId: StorageId
    ) {
      self.id = id
      self.storageId = storageId
    }

    public var __variables: Variables? { [
      "id": id,
      "storageId": storageId
    ] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("moveItem", MoveItem.self, arguments: [
          "id": .variable("id"),
          "storageId": .variable("storageId")
        ]),
      ] }

      /// Move an item to a different storage location
      var moveItem: MoveItem { __data["moveItem"] }

      /// MoveItem
      ///
      /// Parent Type: `Item`
      struct MoveItem: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Item }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.ItemId.self),
          .field("name", BazarGraphQL.ItemName.self),
          .field("location", Location?.self),
        ] }

        /// Item unique identifier
        var id: BazarGraphQL.ItemId { __data["id"] }
        /// Item display name
        var name: BazarGraphQL.ItemName { __data["name"] }
        /// Resolved location path
        var location: Location? { __data["location"] }

        /// MoveItem.Location
        ///
        /// Parent Type: `LocationPath`
        struct Location: BazarGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.LocationPath }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("fullPath", String.self),
          ] }

          /// Full path string (e.g. "Appartement > Cuisine > Placard > Etagere 2")
          var fullPath: String { __data["fullPath"] }
        }
      }
    }
  }

}