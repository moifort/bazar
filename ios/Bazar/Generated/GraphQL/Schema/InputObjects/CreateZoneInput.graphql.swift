// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension BazarGraphQL {
  /// Input for creating a new zone
  struct CreateZoneInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      name: ZoneName,
      roomId: RoomId
    ) {
      __data = InputDict([
        "name": name,
        "roomId": roomId
      ])
    }

    /// Zone name
    var name: ZoneName {
      get { __data["name"] }
      set { __data["name"] = newValue }
    }

    /// Parent room
    var roomId: RoomId {
      get { __data["roomId"] }
      set { __data["roomId"] = newValue }
    }
  }

}