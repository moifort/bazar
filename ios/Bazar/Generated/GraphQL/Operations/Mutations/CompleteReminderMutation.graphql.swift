// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class CompleteReminderMutation: GraphQLMutation {
    static let operationName: String = "CompleteReminder"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CompleteReminder($id: ReminderId!) { completeReminder(id: $id) { __typename id dueDate updatedAt } }"#
      ))

    public var id: ReminderId

    public init(id: ReminderId) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: BazarGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("completeReminder", CompleteReminder?.self, arguments: ["id": .variable("id")]),
      ] }

      /// Mark a reminder as done. Recurring reminders reschedule automatically; one-shot reminders are deleted and null is returned.
      var completeReminder: CompleteReminder? { __data["completeReminder"] }

      /// CompleteReminder
      ///
      /// Parent Type: `Reminder`
      struct CompleteReminder: BazarGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { BazarGraphQL.Objects.Reminder }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", BazarGraphQL.ReminderId.self),
          .field("dueDate", BazarGraphQL.DateTime.self),
          .field("updatedAt", BazarGraphQL.DateTime.self),
        ] }

        var id: BazarGraphQL.ReminderId { __data["id"] }
        var dueDate: BazarGraphQL.DateTime { __data["dueDate"] }
        var updatedAt: BazarGraphQL.DateTime { __data["updatedAt"] }
      }
    }
  }

}