// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class DeleteItemMutation: GraphQLMutation {
    static let operationName: String = "DeleteItem"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeleteItem($id: ItemId!) { deleteItem(id: $id) }"#
      ))

    public var id: ItemId

    public init(id: ItemId) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("deleteItem", Bool.self, arguments: ["id": .variable("id")]),
      ] }

      /// Delete an item and its photo
      var deleteItem: Bool { __data["deleteItem"] }
    }
  }

}