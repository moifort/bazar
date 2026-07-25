// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class ChangelogQuery: GraphQLQuery {
    static let operationName: String = "Changelog"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Changelog { changelog { __typename version date notes } }"#
      ))

    public init() {}

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("changelog", [Changelog].self),
      ] }

      /// The app’s "What’s new" list — one entry per release, newest first. Feeds the changelog screen. For example the `"1.2"` entry with notes `"Faster photo scans"` and `"Fixed a crash when adding an item"`, then the `"1.1"` entry, and so on.
      ///
      /// ```graphql
      /// changelog {
      ///   version
      ///   date
      ///   notes
      /// }
      /// ```
      var changelog: [Changelog] { __data["changelog"] }

      /// Changelog
      ///
      /// Parent Type: `ChangelogEntry`
      struct Changelog: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.ChangelogEntry }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("version", String.self),
          .field("date", BazarGraphQL.DateTime?.self),
          .field("notes", [String].self),
        ] }

        /// The app version these notes are for, e.g. `"1.2"`
        var version: String { __data["version"] }
        /// When that version was released, e.g. `"2026-07-18T00:00:00.000Z"` (`null` for a release not yet dated)
        var date: BazarGraphQL.DateTime? { __data["date"] }
        /// The list of changes in this release, one line each, ready to show to the user, e.g. `"Faster photo scans"` then `"Fixed a crash when adding an item"`
        var notes: [String] { __data["notes"] }
      }
    }
  }

}