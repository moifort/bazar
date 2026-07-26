// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class CompleteOnboardingMutation: GraphQLMutation {
    static let operationName: String = "CompleteOnboarding"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CompleteOnboarding($input: CompleteOnboardingInput!) { completeOnboarding(input: $input) { __typename firstName } }"#
      ))

    public var input: CompleteOnboardingInput

    public init(input: CompleteOnboardingInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("completeOnboarding", CompleteOnboarding.self, arguments: ["input": .variable("input")]),
      ] }

      /// Close the first launch: record how to call you, create your first house and the rooms you picked, all at once. Everything that follows has somewhere to go.
      ///
      /// Answers `ALREADY_ONBOARDED` when you have already been through it — running it twice would hand you a second house.
      ///
      /// ```graphql
      /// completeOnboarding(input: {
      ///   firstName: "Thibaut"
      ///   houseName: "Maison"
      ///   houseIcon: "🏠"
      ///   rooms: [{ name: "Cuisine", icon: "🍳" }]
      /// }) {
      ///   firstName
      /// }
      /// ```
      var completeOnboarding: CompleteOnboarding { __data["completeOnboarding"] }

      /// CompleteOnboarding
      ///
      /// Parent Type: `User`
      struct CompleteOnboarding: BazarGraphQL.SelectionSet {
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
    }
  }

}