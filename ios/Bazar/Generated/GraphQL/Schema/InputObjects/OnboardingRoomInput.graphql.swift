// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// A room to create in the house the onboarding names
  struct OnboardingRoomInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      icon: GraphQLNullable<String> = nil,
      name: RoomName
    ) {
      __data = InputDict([
        "icon": icon,
        "name": name
      ])
    }

    /// Optional emoji icon, e.g. `"🍳"`
    var icon: GraphQLNullable<String> {
      get { __data["icon"] }
      set { __data["icon"] = newValue }
    }

    /// Room name, e.g. `"Cuisine"`
    var name: RoomName {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }
  }

}