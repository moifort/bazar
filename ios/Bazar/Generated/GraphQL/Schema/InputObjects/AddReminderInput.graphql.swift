// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for adding a new reminder to an item
  struct AddReminderInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      customIntervalDays: GraphQLNullable<Int> = nil,
      dueDate: DateTime,
      frequency: GraphQLNullable<GraphQLEnum<ReminderFrequency>> = nil,
      itemId: ItemId,
      notes: GraphQLNullable<String> = nil,
      title: ReminderTitle
    ) {
      __data = InputDict([
        "customIntervalDays": customIntervalDays,
        "dueDate": dueDate,
        "frequency": frequency,
        "itemId": itemId,
        "notes": notes,
        "title": title
      ])
    }

    /// Days between occurrences when frequency is custom_days
    var customIntervalDays: GraphQLNullable<Int> {
      get { __data["customIntervalDays"] }
      set { __data["customIntervalDays"] = newValue }
    }

    /// Next due date
    var dueDate: DateTime {
      get { __data["dueDate"] }
      set { __data["dueDate"] = newValue }
    }

    /// Recurrence cadence (omit for one-shot)
    var frequency: GraphQLNullable<GraphQLEnum<ReminderFrequency>> {
      get { __data["frequency"] }
      set { __data["frequency"] = newValue }
    }

    /// Target item
    var itemId: ItemId {
      get { __data["itemId"] }
      set { __data["itemId"] = newValue }
    }

    /// Free-form notes
    var notes: GraphQLNullable<String> {
      get { __data["notes"] }
      set { __data["notes"] = newValue }
    }

    /// Reminder title
    var title: ReminderTitle {
      get { __data["title"] }
      set { __data["title"] = newValue }
    }
  }

}