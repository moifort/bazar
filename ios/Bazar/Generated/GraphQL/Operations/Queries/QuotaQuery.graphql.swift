// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class QuotaQuery: GraphQLQuery {
    static let operationName: String = "Quota"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Quota { quota { __typename plan used limit remaining renewsOn } }"#
      ))

    public init() {}

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("quota", Quota.self),
      ] }

      /// Your photo-scan allowance for the current month: the plan you are on, what you have spent, what is left and when it renews. The free plan gets 10 scans a month; Premium has no monthly allowance, so `limit` and `remaining` come back `null`.
      ///
      /// ```graphql
      /// quota {
      ///   plan
      ///   used
      ///   limit
      ///   remaining
      ///   renewsOn
      /// }
      /// ```
      var quota: Quota { __data["quota"] }

      /// Quota
      ///
      /// Parent Type: `Quota`
      struct Quota: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Quota }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("plan", GraphQLEnum<BazarGraphQL.Plan>.self),
          .field("used", Int.self),
          .field("limit", Int?.self),
          .field("remaining", Int?.self),
          .field("renewsOn", BazarGraphQL.DateTime.self),
        ] }

        /// The plan in force, e.g. `FREE`
        var plan: GraphQLEnum<BazarGraphQL.Plan> { __data["plan"] }
        /// How many scans were spent this month, e.g. `3`
        var used: Int { __data["used"] }
        /// How many scans the plan allows per month, e.g. `10` — `null` on Premium
        var limit: Int? { __data["limit"] }
        /// How many scans are still available this month, e.g. `7` — `null` on Premium
        var remaining: Int? { __data["remaining"] }
        /// When the counter goes back to zero — the 1st of next month, e.g. `"2026-08-01T00:00:00.000Z"`
        var renewsOn: BazarGraphQL.DateTime { __data["renewsOn"] }
      }
    }
  }

}