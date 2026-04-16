// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class UpdateRoomMutation: GraphQLMutation {
    static let operationName: String = "UpdateRoom"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateRoom($id: RoomId!, $input: UpdateRoomInput!) { updateRoom(id: $id, input: $input) { __typename id placeId name icon order } }"#
      ))

    public var id: RoomId
    public var input: UpdateRoomInput

    public init(
      id: RoomId,
      input: UpdateRoomInput
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
        .field("updateRoom", UpdateRoom.self, arguments: [
          "id": .variable("id"),
          "input": .variable("input")
        ]),
      ] }

      /// Update an existing room
      var updateRoom: UpdateRoom { __data["updateRoom"] }

      /// UpdateRoom
      ///
      /// Parent Type: `Room`
      struct UpdateRoom: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Room }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.RoomId.self),
          .field("placeId", BazarGraphQL.PlaceId.self),
          .field("name", BazarGraphQL.RoomName.self),
          .field("icon", String?.self),
          .field("order", Int.self),
        ] }

        /// Room unique identifier
        var id: BazarGraphQL.RoomId { __data["id"] }
        /// Parent place identifier
        var placeId: BazarGraphQL.PlaceId { __data["placeId"] }
        /// Room display name
        var name: BazarGraphQL.RoomName { __data["name"] }
        /// Optional emoji icon
        var icon: String? { __data["icon"] }
        /// Sort order
        var order: Int { __data["order"] }
      }
    }
  }

}