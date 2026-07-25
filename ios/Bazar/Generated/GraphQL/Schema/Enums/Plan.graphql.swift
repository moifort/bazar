// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// What a user is entitled to. The inventory itself is free and unlimited — the plan only decides how many photo scans come with it.
  enum Plan: String, EnumType {
    /// The free plan — unlimited items, a monthly allowance of photo scans
    case free = "FREE"
    /// The paid subscription — photo scans with no monthly allowance to watch
    case premium = "PREMIUM"
  }

}