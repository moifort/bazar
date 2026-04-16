// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension BazarGraphQL {
  class DeleteReminderMutation: GraphQLMutation {
    static let operationName: String = "DeleteReminder"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DeleteReminder($id: ReminderId!) { deleteReminder(id: $id) }"#
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
        .field("deleteReminder", Bool.self, arguments: ["id": .variable("id")]),
      ] }

      /// Delete a reminder
      var deleteReminder: Bool { __data["deleteReminder"] }
    }
  }

}