// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Recurrence cadence for a reminder
  enum ReminderFrequency: String, EnumType {
    /// Every year
    case annual = "annual"
    /// Every six months
    case biannual = "biannual"
    /// Custom number of days
    case customDays = "custom_days"
    /// Every month
    case monthly = "monthly"
    /// Every three months
    case quarterly = "quarterly"
  }

}