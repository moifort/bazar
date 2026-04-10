// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class DeleteZoneMutation: GraphQLMutation {
    static let operationName: String = "DeleteZone"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeleteZone($id: ZoneId!) { deleteZone(id: $id) }"#
      ))

    public var id: ZoneId

    public init(id: ZoneId) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("deleteZone", Bool.self, arguments: ["id": .variable("id")]),
      ] }

      /// Delete a zone and all its storages
      var deleteZone: Bool { __data["deleteZone"] }
    }
  }

}