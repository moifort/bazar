// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for updating a room
  struct UpdateRoomInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      icon: GraphQLNullable<String> = nil,
      name: GraphQLNullable<RoomName> = nil,
      order: GraphQLNullable<Int> = nil
    ) {
      __data = InputDict([
        "icon": icon,
        "name": name,
        "order": order
      ])
    }

    /// New emoji icon
    var icon: GraphQLNullable<String> {
      get { __data["icon"] }
      set { __data["icon"] = newValue }
    }

    /// New room name
    var name: GraphQLNullable<RoomName> {
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