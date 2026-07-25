// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class EntitlementQuery: GraphQLQuery {
    static let operationName: String = "Entitlement"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Entitlement { entitlement { __typename plan appAccountToken productId expiresOn } }"#
      ))

    public init() {}

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("entitlement", Entitlement.self),
      ] }

      /// What you are entitled to today, and the account token to start a purchase with. The app reads this before showing the subscription sheet.
      ///
      /// ```graphql
      /// entitlement {
      ///   plan
      ///   appAccountToken
      ///   productId
      ///   expiresOn
      /// }
      /// ```
      var entitlement: Entitlement { __data["entitlement"] }

      /// Entitlement
      ///
      /// Parent Type: `Entitlement`
      struct Entitlement: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Entitlement }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("plan", GraphQLEnum<BazarGraphQL.Plan>.self),
          .field("appAccountToken", String.self),
          .field("productId", String?.self),
          .field("expiresOn", BazarGraphQL.DateTime?.self),
        ] }

        /// The plan in force right now, e.g. `PREMIUM`
        var plan: GraphQLEnum<BazarGraphQL.Plan> { __data["plan"] }
        /// The UUID to pass to StoreKit as the purchase’s account token, e.g. `"1f2e3d4c-5b6a-5978-8695-a4b3c2d1e0f9"`. Without it a purchase cannot be matched to you, and syncing it will be refused.
        var appAccountToken: String { __data["appAccountToken"] }
        /// The subscription bought, e.g. `"co.polyforms.bazar.premium.yearly"` — `null` when there is none
        var productId: String? { __data["productId"] }
        /// When the paid period ends, e.g. `"2027-07-20T09:12:00.000Z"` — `null` when there is no subscription. A cancelled subscription keeps its Premium until this date.
        var expiresOn: BazarGraphQL.DateTime? { __data["expiresOn"] }
      }
    }
  }

}