// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class CreateStorageMutation: GraphQLMutation {
    static let operationName: String = "CreateStorage"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateStorage($input: CreateStorageInput!) { createStorage(input: $input) { __typename id zoneId name order } }"#
      ))

    public var input: CreateStorageInput

    public init(input: CreateStorageInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("createStorage", CreateStorage.self, arguments: ["input": .variable("input")]),
      ] }

      /// Create a new storage spot in a zone
      var createStorage: CreateStorage { __data["createStorage"] }

      /// CreateStorage
      ///
      /// Parent Type: `Storage`
      struct CreateStorage: BazarGraphQL.SelectionSet {
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