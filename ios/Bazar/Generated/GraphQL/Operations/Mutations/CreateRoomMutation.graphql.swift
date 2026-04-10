// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class CreateRoomMutation: GraphQLMutation {
    static let operationName: String = "CreateRoom"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateRoom($input: CreateRoomInput!) { createRoom(input: $input) { __typename id placeId name icon order } }"#
      ))

    public var input: CreateRoomInput

    public init(input: CreateRoomInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("createRoom", CreateRoom.self, arguments: ["input": .variable("input")]),
      ] }

      /// Create a new room in a place
      var createRoom: CreateRoom { __data["createRoom"] }

      /// CreateRoom
      ///
      /// Parent Type: `Room`
      struct CreateRoom: BazarGraphQL.SelectionSet {
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