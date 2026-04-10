// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for creating a new room
  struct CreateRoomInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      icon: GraphQLNullable<String> = nil,
      name: RoomName,
      placeId: PlaceId
    ) {
      __data = InputDict([
        "icon": icon,
        "name": name,
        "placeId": placeId
      ])
    }

    /// Optional emoji icon
    var icon: GraphQLNullable<String> {
      get { __data["icon"] }
      set { __data["icon"] = newValue }
    }

    /// Room name
    var name: RoomName {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// Parent place
    var placeId: PlaceId {
      get { __data["placeId"] }
      set { __data["placeId"] = newValue }
    }
  }

}