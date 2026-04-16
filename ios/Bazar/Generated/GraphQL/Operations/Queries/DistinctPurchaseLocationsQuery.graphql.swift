// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class DistinctPurchaseLocationsQuery: GraphQLQuery {
    static let operationName: String = "DistinctPurchaseLocations"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query DistinctPurchaseLocations { distinctPurchaseLocations }"#
      ))

    public init() {}

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("distinctPurchaseLocations", [String].self),
      ] }

      /// Distinct non-empty purchase locations, ordered by frequency desc
      var distinctPurchaseLocations: [String] { __data["distinctPurchaseLocations"] }
    }
  }

}