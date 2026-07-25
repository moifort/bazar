// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class SyncEntitlementMutation: GraphQLMutation {
    static let operationName: String = "SyncEntitlement"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation SyncEntitlement($signedTransaction: String!) { syncEntitlement(signedTransaction: $signedTransaction) { __typename plan appAccountToken productId expiresOn } }"#
      ))

    public var signedTransaction: String

    public init(signedTransaction: String) {
      self.signedTransaction = signedTransaction
    }

    public var __variables: Variables? { ["signedTransaction": signedTransaction] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("syncEntitlement", SyncEntitlement.self, arguments: ["signedTransaction": .variable("signedTransaction")]),
      ] }

      /// Hand over a transaction the App Store signed for you — after a purchase, after a restore, and on every launch while a subscription is running. The signature is verified against Apple’s root certificates and the purchase must carry your `appAccountToken`, so this is what grants Premium: nothing else does.
      ///
      /// Answers `INVALID_TRANSACTION` when the signature does not check out, and `TRANSACTION_NOT_YOURS` when the purchase belongs to another account.
      ///
      /// ```graphql
      /// syncEntitlement(signedTransaction: "eyJhbGciOi...") {
      ///   plan
      ///   expiresOn
      /// }
      /// ```
      var syncEntitlement: SyncEntitlement { __data["syncEntitlement"] }

      /// SyncEntitlement
      ///
      /// Parent Type: `Entitlement`
      struct SyncEntitlement: BazarGraphQL.SelectionSet {
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