// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class CreateZoneMutation: GraphQLMutation {
    static let operationName: String = "CreateZone"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateZone($input: CreateZoneInput!) { createZone(input: $input) { __typename id roomId name order } }"#
      ))

    public var input: CreateZoneInput

    public init(input: CreateZoneInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("createZone", CreateZone.self, arguments: ["input": .variable("input")]),
      ] }

      /// Create a new zone in a room
      var createZone: CreateZone { __data["createZone"] }

      /// CreateZone
      ///
      /// Parent Type: `Zone`
      struct CreateZone: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Zone }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.ZoneId.self),
          .field("roomId", BazarGraphQL.RoomId.self),
          .field("name", BazarGraphQL.ZoneName.self),
          .field("order", Int.self),
        ] }

        /// Zone unique identifier
        var id: BazarGraphQL.ZoneId { __data["id"] }
        /// Parent room identifier
        var roomId: BazarGraphQL.RoomId { __data["roomId"] }
        /// Zone display name
        var name: BazarGraphQL.ZoneName { __data["name"] }
        /// Sort order
        var order: Int { __data["order"] }
      }
    }
  }

}