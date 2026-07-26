// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class OnboardingStateQuery: GraphQLQuery {
    static let operationName: String = "OnboardingState"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query OnboardingState { me { __typename firstName } places { __typename id } }"#
      ))

    public init() {}

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("me", Me?.self),
        .field("places", [Place].self),
      ] }

      /// Who you are, as you introduced yourself. `null` means you never went through the onboarding — which is exactly what the app reads on launch to decide whether to run it.
      ///
      /// ```graphql
      /// me {
      ///   firstName
      ///   onboardedOn
      /// }
      /// ```
      var me: Me? { __data["me"] }
      /// All places with nested rooms, zones, and storages
      var places: [Place] { __data["places"] }

      /// Me
      ///
      /// Parent Type: `User`
      struct Me: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.User }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("firstName", BazarGraphQL.FirstName.self),
        ] }

        /// How to call the user, e.g. `"Thibaut"`
        var firstName: BazarGraphQL.FirstName { __data["firstName"] }
      }

      /// Place
      ///
      /// Parent Type: `Place`
      struct Place: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Place }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.PlaceId.self),
        ] }

        /// Place unique identifier
        var id: BazarGraphQL.PlaceId { __data["id"] }
      }
    }
  }

}