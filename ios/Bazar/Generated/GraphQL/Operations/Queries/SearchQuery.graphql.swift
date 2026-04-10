// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class SearchQuery: GraphQLQuery {
    static let operationName: String = "Search"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Search($query: String!, $limit: Int) { search(query: $query, limit: $limit) { __typename type entityId text } }"#
      ))

    public var query: String
    public var limit: GraphQLNullable<Int>

    public init(
      query: String,
      limit: GraphQLNullable<Int>
    ) {
      self.query = query
      self.limit = limit
    }

    public var __variables: Variables? { [
      "query": query,
      "limit": limit
    ] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("search", [Search].self, arguments: [
          "query": .variable("query"),
          "limit": .variable("limit")
        ]),
      ] }

      /// Full-text search across items and locations
      var search: [Search] { __data["search"] }

      /// Search
      ///
      /// Parent Type: `SearchEntry`
      struct Search: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.SearchEntry }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("type", String.self),
          .field("entityId", String.self),
          .field("text", String.self),
        ] }

        /// Entry type (item, place, room)
        var type: String { __data["type"] }
        /// ID of the matched entity
        var entityId: String { __data["entityId"] }
        /// Matched text content
        var text: String { __data["text"] }
      }
    }
  }

}