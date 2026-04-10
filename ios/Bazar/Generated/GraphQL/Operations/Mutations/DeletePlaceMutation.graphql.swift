// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class DeletePlaceMutation: GraphQLMutation {
    static let operationName: String = "DeletePlace"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeletePlace($id: PlaceId!) { deletePlace(id: $id) }"#
      ))

    public var id: PlaceId

    public init(id: PlaceId) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("deletePlace", Bool.self, arguments: ["id": .variable("id")]),
      ] }

      /// Delete a place and all its rooms, zones, and storages
      var deletePlace: Bool { __data["deletePlace"] }
    }
  }

}