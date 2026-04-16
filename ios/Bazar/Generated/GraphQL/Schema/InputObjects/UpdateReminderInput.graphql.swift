// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for updating an existing reminder
  struct UpdateReminderInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      customIntervalDays: GraphQLNullable<Int> = nil,
      dueDate: GraphQLNullable<DateTime> = nil,
      frequency: GraphQLNullable<GraphQLEnum<ReminderFrequency>> = nil,
      notes: GraphQLNullable<String> = nil,
      title: GraphQLNullable<ReminderTitle> = nil
    ) {
      __data = InputDict([
        "customIntervalDays": customIntervalDays,
        "dueDate": dueDate,
        "frequency": frequency,
        "notes": notes,
        "title": title
      ])
    }

    /// Custom interval in days (only when frequency is custom_days)
    var customIntervalDays: GraphQLNullable<Int> {
      get { __data["customIntervalDays"] }
      set { __data["customIntervalDays"] = newValue }
    }

    /// New due date
    var dueDate: GraphQLNullable<DateTime> {
      get { __data["dueDate"] }
      set { __data["dueDate"] = newValue }
    }

    /// New recurrence cadence (explicit null clears it)
    var frequency: GraphQLNullable<GraphQLEnum<ReminderFrequency>> {
      get { __data["frequency"] }
      set { __data["frequency"] = newValue }
    }

    /// New notes
    var notes: GraphQLNullable<String> {
      get { __data["notes"] }
      set { __data["notes"] = newValue }
    }

    /// New title
    var title: GraphQLNullable<ReminderTitle> {
      get { __data["title"] }
      set { __data["title"] = newValue }
    }
  }

}