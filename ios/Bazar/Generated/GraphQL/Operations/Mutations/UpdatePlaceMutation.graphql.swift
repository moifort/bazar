// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class UpdatePlaceMutation: GraphQLMutation {
    static let operationName: String = "UpdatePlace"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdatePlace($id: PlaceId!, $input: UpdatePlaceInput!) { updatePlace(id: $id, input: $input) { __typename id name icon order } }"#
      ))

    public var id: PlaceId
    public var input: UpdatePlaceInput

    public init(
      id: PlaceId,
      input: UpdatePlaceInput
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
        .field("updatePlace", UpdatePlace.self, arguments: [
          "id": .variable("id"),
          "input": .variable("input")
        ]),
      ] }

      /// Update an existing place
      var updatePlace: UpdatePlace { __data["updatePlace"] }

      /// UpdatePlace
      ///
      /// Parent Type: `Place`
      struct UpdatePlace: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Place }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.PlaceId.self),
          .field("name", BazarGraphQL.PlaceName.self),
          .field("icon", String?.self),
          .field("order", Int.self),
        ] }

        /// Place unique identifier
        var id: BazarGraphQL.PlaceId { __data["id"] }
        /// Place display name
        var name: BazarGraphQL.PlaceName { __data["name"] }
        /// Optional emoji icon
        var icon: String? { __data["icon"] }
        /// Sort order
        var order: Int { __data["order"] }
      }
    }
  }

}