// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class UpdateStorageMutation: GraphQLMutation {
    static let operationName: String = "UpdateStorage"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateStorage($id: StorageId!, $input: UpdateStorageInput!) { updateStorage(id: $id, input: $input) { __typename id zoneId name order } }"#
      ))

    public var id: StorageId
    public var input: UpdateStorageInput

    public init(
      id: StorageId,
      input: UpdateStorageInput
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
        .field("updateStorage", UpdateStorage.self, arguments: [
          "id": .variable("id"),
          "input": .variable("input")
        ]),
      ] }

      /// Update an existing storage spot
      var updateStorage: UpdateStorage { __data["updateStorage"] }

      /// UpdateStorage
      ///
      /// Parent Type: `Storage`
      struct UpdateStorage: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Storage }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.StorageId.self),
          .field("zoneId", BazarGraphQL.ZoneId.self),
          .field("name", BazarGraphQL.StorageName.self),
          .field("order", Int.self),
        ] }

        /// Storage unique identifier
        var id: BazarGraphQL.StorageId { __data["id"] }
        /// Parent zone identifier
        var zoneId: BazarGraphQL.ZoneId { __data["zoneId"] }
        /// Storage display name
        var name: BazarGraphQL.StorageName { __data["name"] }
        /// Sort order
        var order: Int { __data["order"] }
      }
    }
  }

}