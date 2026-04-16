// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class UpdateZoneMutation: GraphQLMutation {
    static let operationName: String = "UpdateZone"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateZone($id: ZoneId!, $input: UpdateZoneInput!) { updateZone(id: $id, input: $input) { __typename id roomId name order } }"#
      ))

    public var id: ZoneId
    public var input: UpdateZoneInput

    public init(
      id: ZoneId,
      input: UpdateZoneInput
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
        .field("updateZone", UpdateZone.self, arguments: [
          "id": .variable("id"),
          "input": .variable("input")
        ]),
      ] }

      /// Update an existing zone
      var updateZone: UpdateZone { __data["updateZone"] }

      /// UpdateZone
      ///
      /// Parent Type: `Zone`
      struct UpdateZone: BazarGraphQL.SelectionSet {
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