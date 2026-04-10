// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class DeleteStorageMutation: GraphQLMutation {
    static let operationName: String = "DeleteStorage"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeleteStorage($id: StorageId!) { deleteStorage(id: $id) }"#
      ))

    public var id: StorageId

    public init(id: StorageId) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("deleteStorage", Bool.self, arguments: ["id": .variable("id")]),
      ] }

      /// Delete a storage spot
      var deleteStorage: Bool { __data["deleteStorage"] }
    }
  }

}