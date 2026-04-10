// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class DeleteRoomMutation: GraphQLMutation {
    static let operationName: String = "DeleteRoom"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeleteRoom($id: RoomId!) { deleteRoom(id: $id) }"#
      ))

    public var id: RoomId

    public init(id: RoomId) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("deleteRoom", Bool.self, arguments: ["id": .variable("id")]),
      ] }

      /// Delete a room and all its zones and storages
      var deleteRoom: Bool { __data["deleteRoom"] }
    }
  }

}