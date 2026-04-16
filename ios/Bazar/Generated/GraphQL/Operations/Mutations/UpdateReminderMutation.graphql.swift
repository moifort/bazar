// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class UpdateReminderMutation: GraphQLMutation {
    static let operationName: String = "UpdateReminder"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateReminder($id: ReminderId!, $input: UpdateReminderInput!) { updateReminder(id: $id, input: $input) { __typename id title notes dueDate frequency customIntervalDays updatedAt } }"#
      ))

    public var id: ReminderId
    public var input: UpdateReminderInput

    public init(
      id: ReminderId,
      input: UpdateReminderInput
    ) {
      self.id = id
      self.input = input
    }

    public var __variables: Variables? { [
      "id": id,
      "input": input
    ] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("updateReminder", UpdateReminder.self, arguments: [
          "id": .variable("id"),
          "input": .variable("input")
        ]),
      ] }

      /// Update an existing reminder
      var updateReminder: UpdateReminder { __data["updateReminder"] }

      /// UpdateReminder
      ///
      /// Parent Type: `Reminder`
      struct UpdateReminder: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Reminder }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.ReminderId.self),
          .field("title", BazarGraphQL.ReminderTitle.self),
          .field("notes", String.self),
          .field("dueDate", BazarGraphQL.DateTime.self),
          .field("frequency", GraphQLEnum<BazarGraphQL.ReminderFrequency>?.self),
          .field("customIntervalDays", Int?.self),
          .field("updatedAt", BazarGraphQL.DateTime.self),
        ] }

        var id: BazarGraphQL.ReminderId { __data["id"] }
        var title: BazarGraphQL.ReminderTitle { __data["title"] }
        var notes: String { __data["notes"] }
        var dueDate: BazarGraphQL.DateTime { __data["dueDate"] }
        var frequency: GraphQLEnum<BazarGraphQL.ReminderFrequency>? { __data["frequency"] }
        var customIntervalDays: Int? { __data["customIntervalDays"] }
        var updatedAt: BazarGraphQL.DateTime { __data["updatedAt"] }
      }
    }
  }

}