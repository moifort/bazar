// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class AddReminderMutation: GraphQLMutation {
    static let operationName: String = "AddReminder"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AddReminder($input: AddReminderInput!) { addReminder(input: $input) { __typename id itemId title notes dueDate frequency customIntervalDays createdAt updatedAt } }"#
      ))

    public var input: AddReminderInput

    public init(input: AddReminderInput) {
      self.input = input
    }

    public var __variables: Variables? { ["input": input] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("addReminder", AddReminder.self, arguments: ["input": .variable("input")]),
      ] }

      /// Add a new reminder to an item
      var addReminder: AddReminder { __data["addReminder"] }

      /// AddReminder
      ///
      /// Parent Type: `Reminder`
      struct AddReminder: BazarGraphQL.SelectionSet {
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