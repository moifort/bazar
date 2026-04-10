// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class CreatePlaceMutation: GraphQLMutation {
    static let operationName: String = "CreatePlace"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreatePlace($input: CreatePlaceInput!) { createPlace(input: $input) { __typename id name icon order } }"#
      ))

    public var input: CreatePlaceInput

    public init(input: CreatePlaceInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("createPlace", CreatePlace.self, arguments: ["input": .variable("input")]),
      ] }

      /// Create a new place (e.g. Appartement, Cave)
      var createPlace: CreatePlace { __data["createPlace"] }

      /// CreatePlace
      ///
      /// Parent Type: `Place`
      struct CreatePlace: BazarGraphQL.SelectionSet {
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