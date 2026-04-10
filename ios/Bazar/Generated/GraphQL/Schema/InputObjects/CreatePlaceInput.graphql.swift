// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for creating a new place
  struct CreatePlaceInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      icon: GraphQLNullable<String> = nil,
      name: PlaceName
    ) {
      __data = InputDict([
        "icon": icon,
        "name": name
      ])
    }

    /// Optional emoji icon
    var icon: GraphQLNullable<String> {
      get { __data["icon"] }
      set { __data["icon"] = newValue }
    }

    /// Place name
    var name: PlaceName {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }
  }

}