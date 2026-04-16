// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class RemindersDueQuery: GraphQLQuery {
    static let operationName: String = "RemindersDue"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query RemindersDue($before: DateTime!) { remindersDue(before: $before) { __typename id itemId title notes dueDate frequency customIntervalDays createdAt updatedAt } }"#
      ))

    public var before: DateTime

    public init(before: DateTime) {
      self.before = before
    }

    public var __variables: Variables? { ["before": before] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("remindersDue", [RemindersDue].self, arguments: ["before": .variable("before")]),
      ] }

      /// Reminders whose dueDate is on or before the given timestamp
      var remindersDue: [RemindersDue] { __data["remindersDue"] }

      /// RemindersDue
      ///
      /// Parent Type: `Reminder`
      struct RemindersDue: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Reminder }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.ReminderId.self),
          .field("itemId", BazarGraphQL.ItemId.self),
          .field("title", BazarGraphQL.ReminderTitle.self),
          .field("notes", String.self),
          .field("dueDate", BazarGraphQL.DateTime.self),
          .field("frequency", GraphQLEnum<BazarGraphQL.ReminderFrequency>?.self),
          .field("customIntervalDays", Int?.self),
          .field("createdAt", BazarGraphQL.DateTime.self),
          .field("updatedAt", BazarGraphQL.DateTime.self),
        ] }

        var id: BazarGraphQL.ReminderId { __data["id"] }
        var itemId: BazarGraphQL.ItemId { __data["itemId"] }
        var title: BazarGraphQL.ReminderTitle { __data["title"] }
        var notes: String { __data["notes"] }
        var dueDate: BazarGraphQL.DateTime { __data["dueDate"] }
        var frequency: GraphQLEnum<BazarGraphQL.ReminderFrequency>? { __data["frequency"] }
        var customIntervalDays: Int? { __data["customIntervalDays"] }
        var createdAt: BazarGraphQL.DateTime { __data["createdAt"] }
        var updatedAt: BazarGraphQL.DateTime { __data["updatedAt"] }
      }
    }
  }

}