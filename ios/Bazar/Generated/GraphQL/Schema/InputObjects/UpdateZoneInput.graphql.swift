// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for updating a zone
  struct UpdateZoneInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      name: GraphQLNullable<ZoneName> = nil,
      order: GraphQLNullable<Int> = nil
    ) {
      __data = InputDict([
        "name": name,
        "order": order
      ])
    }

    /// New zone name
    var name: GraphQLNullable<ZoneName> {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// New sort order
    var order: GraphQLNullable<Int> {
      get { __data["order"] }
      set { __data["order"] = newValue }
    }
  }

}